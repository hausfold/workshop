import Foundation

/// What the policy engine decides to do with one event.
enum DeliveryDecision: Equatable, Sendable {
    /// Draw a banner now (and record to the inbox).
    case banner
    /// No banner; the event lands in the inbox only.
    case inboxOnly
    /// Batch into a named digest, flushed on the digest's schedule.
    case digest(String)
    /// Discard entirely (never persisted).
    case drop
}

/// Declarative filtering, loaded from `~/.config/flick/rules.json`.
/// First matching rule wins; no rule → banner. Kept deliberately small:
/// common cases stay declarative, anything fancier is a future opt-in hook,
/// never an implicit shell-out per event.
struct RuleSet: Codable, Sendable, Equatable {
    struct Rule: Codable, Sendable, Equatable {
        struct Match: Codable, Sendable, Equatable {
            /// Exact source slug/bundle id (case-insensitive).
            var source: String?
            /// Substring match on the normalized title (case-insensitive).
            var titleContains: String?
            /// Rule applies only at or below this urgency.
            var urgencyAtMost: NotificationEvent.Urgency?

            func matches(_ event: NotificationEvent) -> Bool {
                if let source, event.source != source.lowercased() { return false }
                if let titleContains,
                   !event.title.localizedCaseInsensitiveContains(titleContains) { return false }
                if let urgencyAtMost, event.urgency > urgencyAtMost { return false }
                return true
            }
        }

        enum Delivery: Codable, Sendable, Equatable {
            case banner
            case inbox
            case digest(String)
            case drop

            // Encoded as {"delivery": "digest", "digest": "work"} alongside
            // the rule's other keys — flat JSON a human writes by hand.
        }

        var match: Match
        var delivery: Delivery
    }

    struct QuietHours: Codable, Sendable, Equatable {
        /// Minutes since local midnight; a window may cross midnight
        /// (start 1320 / end 420 = 22:00–07:00).
        var startMinute: Int
        var endMinute: Int

        func contains(minuteOfDay minute: Int) -> Bool {
            if startMinute == endMinute { return false }
            if startMinute < endMinute {
                return minute >= startMinute && minute < endMinute
            }
            return minute >= startMinute || minute < endMinute
        }
    }

    var rules: [Rule]
    var quietHours: QuietHours?

    static let empty = RuleSet(rules: [], quietHours: nil)
}

extension RuleSet.Rule.Delivery {
    private enum CodingKeys: String, CodingKey { case delivery, digest }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        switch try c.decode(String.self, forKey: .delivery) {
        case "banner": self = .banner
        case "inbox": self = .inbox
        case "drop": self = .drop
        case "digest":
            self = .digest(try c.decodeIfPresent(String.self, forKey: .digest) ?? "default")
        case let other:
            throw DecodingError.dataCorruptedError(
                forKey: .delivery, in: c,
                debugDescription: "unknown delivery '\(other)'"
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .banner: try c.encode("banner", forKey: .delivery)
        case .inbox: try c.encode("inbox", forKey: .delivery)
        case .drop: try c.encode("drop", forKey: .delivery)
        case .digest(let name):
            try c.encode("digest", forKey: .delivery)
            try c.encode(name, forKey: .digest)
        }
    }
}
