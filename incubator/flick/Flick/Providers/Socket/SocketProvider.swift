import Foundation

/// The scriptability backbone: `flick send …`, nix rebuild hooks, pounce
/// commands, trill — anything local — writes one JSON line to the socket and
/// gets one JSON line back. Wire format is versioned so old CLIs keep
/// working against newer daemons.
struct SocketProvider: NotificationProvider {
    let name = "socket"
    let capabilities = ProviderCapabilities(canOpenSource: false, canDismissAtSource: false)

    /// One JSON object per line. `v` is the wire version.
    struct Request: Codable {
        var v: Int?
        /// "send" | "ping"
        var verb: String
        var event: NotificationEvent?
    }

    struct Response: Codable {
        var ok: Bool
        var id: String?
        var error: String?
    }

    static func defaultSocketPath() -> String {
        AppPaths.supportDirectory.appendingPathComponent("flick.sock").path
    }

    private let path: String
    init(path: String = SocketProvider.defaultSocketPath()) {
        self.path = path
    }

    func probe() async -> ProviderHealth {
        do {
            try FileManager.default.createDirectory(
                at: AppPaths.supportDirectory, withIntermediateDirectories: true
            )
            return .ready
        } catch {
            return .unavailable(reason: "cannot create \(AppPaths.supportDirectory.path)")
        }
    }

    func events() async -> AsyncStream<NotificationEvent> {
        AsyncStream { continuation in
            let decoder = JSONDecoder.flick
            let encoder = JSONEncoder.flick

            let server = SocketServer(path: path) { line, reply in
                let response: Response
                switch Self.handle(line: line, decoder: decoder) {
                case .send(let event):
                    continuation.yield(event)
                    response = Response(ok: true, id: event.id, error: nil)
                case .ping:
                    response = Response(ok: true, id: nil, error: nil)
                case .failure(let message):
                    response = Response(ok: false, id: nil, error: message)
                }
                reply((try? encoder.encode(response)) ?? Data(#"{"ok":false}"#.utf8))
            }

            do {
                try server.start()
            } catch {
                // Finishing hands control to the supervisor: re-probe,
                // backoff, retry. The rest of the app never notices.
                continuation.finish()
                return
            }
            continuation.onTermination = { _ in server.stop() }
        }
    }

    enum Handled {
        case send(NotificationEvent)
        case ping
        case failure(String)
    }

    /// Pure request handling, testable without a socket.
    static func handle(line: Data, decoder: JSONDecoder = .flick) -> Handled {
        let request: Request
        do {
            request = try decoder.decode(Request.self, from: line)
        } catch {
            return .failure("invalid JSON request")
        }
        switch request.verb {
        case "ping":
            return .ping
        case "send":
            guard let event = request.event else { return .failure("send requires an event") }
            guard !event.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return .failure("event.title must not be empty")
            }
            return .send(event.normalized())
        case let other:
            return .failure("unknown verb '\(other)'")
        }
    }
}

enum AppPaths {
    static var supportDirectory: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Flick", isDirectory: true)
    }

    static var configDirectory: URL {
        let home = FileManager.default.homeDirectoryForCurrentUser
        return home.appendingPathComponent(".config/flick", isDirectory: true)
    }

    static var rulesFile: URL { configDirectory.appendingPathComponent("rules.json") }
    static var databaseFile: URL { supportDirectory.appendingPathComponent("flick.db") }
}

extension JSONDecoder {
    static var flick: JSONDecoder {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }
}

extension JSONEncoder {
    static var flick: JSONEncoder {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        e.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return e
    }
}
