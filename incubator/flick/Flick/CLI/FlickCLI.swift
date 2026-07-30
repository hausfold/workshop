import Foundation

/// The scriptable face:
///
///   flick send --title "Deploy landed" [--body …] [--source deploy]
///              [--symbol checkmark.circle] [--thread deploys]
///              [--urgency low|normal|critical] [--redact] [--url https://…]
///   echo '{"title":"Backup complete"}' | flick send --json
///   flick ping
///
/// One JSON line out, one JSON line back, exit code says what happened:
/// 0 ok · 1 bad usage · 2 daemon unreachable · 3 daemon refused.
enum FlickCLI {
    static let subcommands: Set<String> = ["send", "ping", "help", "--help", "-h"]

    static func run(arguments: [String]) -> Int32 {
        switch arguments.first {
        case "ping":
            return roundTrip(SocketProvider.Request(v: 1, verb: "ping", event: nil))
        case "send":
            switch parseSend(Array(arguments.dropFirst())) {
            case .success(let event):
                return roundTrip(SocketProvider.Request(v: 1, verb: "send", event: event))
            case .failure(let message):
                FileHandle.standardError.write(Data("flick: \(message)\n".utf8))
                return 1
            }
        default:
            print(usage)
            return arguments.first.map { ["help", "--help", "-h"].contains($0) } == true ? 0 : 1
        }
    }

    // MARK: - Parsing

    enum ParseResult {
        case success(NotificationEvent)
        case failure(String)
    }

    static func parseSend(_ args: [String]) -> ParseResult {
        if args.contains("--json") {
            let data = FileHandle.standardInput.readDataToEndOfFile()
            guard var event = try? JSONDecoder.flick.decode(NotificationEvent.self, from: data) else {
                return .failure("stdin was not a valid event JSON object")
            }
            if event.source.isEmpty { event.source = "cli" }
            return .success(event)
        }

        var title: String?
        var body: String?
        var subtitle: String?
        var source = "cli"
        var symbol: String?
        var thread: String?
        var urgency = NotificationEvent.Urgency.normal
        var privacy = NotificationEvent.Privacy.visible
        var actions: [NotificationEvent.Action] = []

        var iterator = args.makeIterator()
        while let flag = iterator.next() {
            func value() -> String? { iterator.next() }
            switch flag {
            case "--title": title = value()
            case "--body": body = value()
            case "--subtitle": subtitle = value()
            case "--source": source = value() ?? source
            case "--symbol": symbol = value()
            case "--thread": thread = value()
            case "--redact": privacy = .redacted
            case "--urgency":
                guard let raw = value(), let parsed = NotificationEvent.Urgency(rawValue: raw) else {
                    return .failure("--urgency wants low|normal|critical")
                }
                urgency = parsed
            case "--url":
                guard let raw = value() else { return .failure("--url wants a value") }
                actions.append(.init(id: "url", label: "Open", kind: .openURL, target: raw))
            default:
                return .failure("unknown flag '\(flag)' (see `flick help`)")
            }
        }

        guard let title, !title.isEmpty else {
            return .failure("send requires --title (or --json on stdin)")
        }
        return .success(NotificationEvent(
            source: source, title: title, subtitle: subtitle, body: body,
            symbol: symbol, thread: thread, urgency: urgency, privacy: privacy,
            actions: actions
        ))
    }

    // MARK: - Socket round trip

    private static func roundTrip(_ request: SocketProvider.Request) -> Int32 {
        let path = SocketProvider.defaultSocketPath()
        guard let payload = try? JSONEncoder.flick.encode(request) else { return 1 }

        let fd = socket(AF_UNIX, SOCK_STREAM, 0)
        guard fd >= 0 else { return 2 }
        defer { close(fd) }

        var addr = sockaddr_un()
        addr.sun_family = sa_family_t(AF_UNIX)
        let fits = withUnsafeMutableBytes(of: &addr.sun_path) { raw -> Bool in
            let bytes = Array(path.utf8)
            guard bytes.count < raw.count else { return false }
            raw.copyBytes(from: bytes)
            return true
        }
        guard fits else { return 2 }

        let size = socklen_t(MemoryLayout<sockaddr_un>.size)
        let connected = withUnsafePointer(to: &addr) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { connect(fd, $0, size) }
        }
        guard connected == 0 else {
            FileHandle.standardError.write(Data("flick: daemon not running (no socket at \(path))\n".utf8))
            return 2
        }

        var out = payload
        out.append(0x0A)
        let sent = out.withUnsafeBytes { raw -> Bool in
            var offset = 0
            while offset < raw.count {
                let n = write(fd, raw.baseAddress! + offset, raw.count - offset)
                if n <= 0 { return false }
                offset += n
            }
            return true
        }
        guard sent else { return 2 }

        // Read one response line (the daemon answers promptly or not at all).
        var buffer = Data()
        var chunk = [UInt8](repeating: 0, count: 4096)
        while !buffer.contains(0x0A) {
            let n = read(fd, &chunk, chunk.count)
            guard n > 0 else { break }
            buffer.append(contentsOf: chunk[0..<n])
            if buffer.count > 64 * 1024 { break }
        }
        guard let nl = buffer.firstIndex(of: 0x0A),
              let response = try? JSONDecoder.flick.decode(
                  SocketProvider.Response.self, from: buffer.prefix(upTo: nl)
              )
        else { return 2 }

        if response.ok {
            if let id = response.id { print(id) }
            return 0
        }
        FileHandle.standardError.write(Data("flick: \(response.error ?? "refused")\n".utf8))
        return 3
    }

    static let usage = """
    flick — a quiet, scriptable notification compositor for macOS

    usage:
      flick send --title TEXT [--body TEXT] [--subtitle TEXT] [--source NAME]
                 [--symbol SFNAME] [--thread NAME] [--urgency low|normal|critical]
                 [--redact] [--url URL]
      flick send --json          # full NotificationEvent JSON on stdin
      flick ping                 # is the daemon up?
      flick help

    exit codes: 0 ok · 1 bad usage · 2 daemon unreachable · 3 daemon refused
    """
}
