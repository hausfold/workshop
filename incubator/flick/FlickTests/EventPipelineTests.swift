import XCTest
@testable import Flick

final class EventPipelineTests: XCTestCase {
    // MARK: - Normalization

    func testNormalizationTrimsAndCaps() {
        let noisy = NotificationEvent(
            source: "  Deploy  ",
            title: "  " + String(repeating: "t", count: 500) + "  ",
            subtitle: "   ",
            body: String(repeating: "b", count: 5000)
        )
        let clean = noisy.normalized()

        XCTAssertEqual(clean.source, "deploy")
        XCTAssertEqual(clean.title.count, NotificationEvent.Limits.title)
        XCTAssertNil(clean.subtitle, "whitespace-only subtitle drops to nil")
        XCTAssertEqual(clean.body?.count, NotificationEvent.Limits.body)
    }

    func testEventRoundTripsThroughWireFormat() throws {
        let event = NotificationEvent(
            source: "trill",
            title: "New message",
            body: "hey",
            symbol: "message",
            thread: "chat-42",
            urgency: .critical,
            privacy: .redacted,
            actions: [.init(id: "open", label: "Open", kind: .openApp, target: "com.nebelhaus.trill")],
            metadata: ["conversation": "42"]
        )
        let data = try JSONEncoder.flick.encode(event)
        let decoded = try JSONDecoder.flick.decode(NotificationEvent.self, from: data)
        // ISO8601 drops sub-second precision; compare everything else.
        XCTAssertEqual(decoded.id, event.id)
        XCTAssertEqual(decoded.actions, event.actions)
        XCTAssertEqual(decoded.privacy, event.privacy)
        XCTAssertEqual(decoded.metadata, event.metadata)
    }

    // MARK: - Socket request handling (pure, no socket)

    func testSocketHandlerAcceptsSend() throws {
        let line = Data(#"{"v":1,"verb":"send","event":{"id":"e1","source":"CI","timestamp":"2026-07-30T12:00:00Z","title":" build green ","urgency":"low","privacy":"visible","actions":[],"metadata":{}}}"#.utf8)
        guard case .send(let event) = SocketProvider.handle(line: line) else {
            return XCTFail("expected send")
        }
        XCTAssertEqual(event.source, "ci", "handler returns normalized events")
        XCTAssertEqual(event.title, "build green")
    }

    func testSocketHandlerRefusesGarbageAndEmptyTitles() {
        if case .failure = SocketProvider.handle(line: Data("not json".utf8)) {} else {
            XCTFail("garbage must fail")
        }
        let untitled = Data(#"{"verb":"send","event":{"id":"e2","source":"x","timestamp":"2026-07-30T12:00:00Z","title":"   ","urgency":"normal","privacy":"visible","actions":[],"metadata":{}}}"#.utf8)
        if case .failure = SocketProvider.handle(line: untitled) {} else {
            XCTFail("blank title must fail")
        }
        if case .ping = SocketProvider.handle(line: Data(#"{"verb":"ping"}"#.utf8)) {} else {
            XCTFail("ping must pong")
        }
    }

    // MARK: - CLI parsing (pure, no daemon)

    func testCLIParsesPartialJSONFromStdin() throws {
        let partialJSON = Data(#"{"title":"From JSON","body":"one line in","source":"ci"}"#.utf8)
        let decoded = try JSONDecoder.flick.decode(NotificationEvent.self, from: partialJSON)
        XCTAssertEqual(decoded.title, "From JSON")
        XCTAssertEqual(decoded.body, "one line in")
        XCTAssertEqual(decoded.source, "ci")
        XCTAssertEqual(decoded.urgency, .normal)
        XCTAssertEqual(decoded.privacy, .visible)
    }

    func testCLIParsesFlagsIntoEvent() throws {
        let result = FlickCLI.parseSend([
            "--title", "Landing page shipped",
            "--body", "Preview promoted to production",
            "--source", "deploy",
            "--symbol", "checkmark.circle",
            "--thread", "deploys",
            "--urgency", "low",
            "--url", "https://nebelhaus.com",
        ])
        guard case .success(let event) = result else { return XCTFail("parse failed") }
        XCTAssertEqual(event.title, "Landing page shipped")
        XCTAssertEqual(event.thread, "deploys")
        XCTAssertEqual(event.urgency, .low)
        XCTAssertEqual(event.actions.first?.kind, .openURL)
    }

    func testCLIRefusesMissingTitleAndBadUrgency() {
        if case .success = FlickCLI.parseSend(["--body", "no title"]) {
            XCTFail("missing title must fail")
        }
        if case .success = FlickCLI.parseSend(["--title", "x", "--urgency", "loud"]) {
            XCTFail("bad urgency must fail")
        }
    }

    // MARK: - Dedupe window

    func testDedupeWindowRejectsRepeatsAndAgesOut() {
        var window = OrderedIDWindow(capacity: 3)
        XCTAssertTrue(window.insert("a"))
        XCTAssertFalse(window.insert("a"))
        XCTAssertTrue(window.insert("b"))
        XCTAssertTrue(window.insert("c"))
        XCTAssertTrue(window.insert("d"), "capacity 3: d evicts a")
        XCTAssertTrue(window.insert("a"), "a aged out, may return")
        XCTAssertFalse(window.insert("d"), "d is still inside the window")
    }

    // MARK: - Banner queue (main-actor scheduling)

    @MainActor
    func testQueueCoalescesThreadBurstsAndRefills() {
        let queue = BannerQueue(capacity: 2, displayDuration: .seconds(3600), coalesceWindow: 10)

        queue.enqueue(NotificationEvent(id: "1", source: "s", title: "first", thread: "t"))
        queue.enqueue(NotificationEvent(id: "2", source: "s", title: "second", thread: "t"))
        XCTAssertEqual(queue.visible.count, 1, "thread-mates coalesce, not stack")
        XCTAssertEqual(queue.visible[0].coalescedCount, 1)
        XCTAssertEqual(queue.visible[0].event.title, "second", "newest content wins the banner face")
        XCTAssertEqual(
            queue.visible[0].folded.map(\.title), ["first"],
            "the folded event is kept, not just counted — hover lists it"
        )
        XCTAssertEqual(
            queue.visible[0].id, "1",
            "the fold keeps the id it was created with; panels and timers key off it"
        )

        queue.enqueue(NotificationEvent(id: "3", source: "a", title: "third"))
        queue.enqueue(NotificationEvent(id: "4", source: "b", title: "fourth"))
        XCTAssertEqual(queue.visible.count, 2, "capacity bounds the visible set")

        queue.dismiss(id: queue.visible[0].id)
        XCTAssertEqual(queue.visible.count, 2, "waiting entry refills the freed slot")
        XCTAssertTrue(queue.visible.contains { $0.id == "4" })
    }

    @MainActor
    func testCapacityShrinkPushesOverflowBackToWaitingNotOblivion() {
        let queue = BannerQueue(capacity: 3, displayDuration: .seconds(3600))
        for i in 1...3 {
            queue.enqueue(NotificationEvent(id: "\(i)", source: "s", title: "\(i)"))
        }
        queue.setCapacity(1) // topology change: smaller display
        XCTAssertEqual(queue.visible.count, 1)

        queue.setCapacity(3) // display came back
        XCTAssertEqual(queue.visible.count, 3, "no event was lost to the rebuild")
    }

    @MainActor
    func testFoldKeepsAPreviewAndAnHonestCount() {
        let queue = BannerQueue(capacity: 2, displayDuration: .seconds(3600), coalesceWindow: 10)
        for i in 1...12 {
            queue.enqueue(NotificationEvent(id: "\(i)", source: "s", title: "msg \(i)", thread: "t"))
        }

        let entry = queue.visible[0]
        XCTAssertEqual(entry.event.title, "msg 12")
        XCTAssertEqual(entry.coalescedCount, 11, "the count is of everything behind the face")
        XCTAssertEqual(
            entry.folded.count, BannerQueue.Entry.foldPreviewLimit,
            "the list is bounded; the count is not"
        )
        XCTAssertEqual(
            entry.folded.map(\.title).prefix(3), ["msg 11", "msg 10", "msg 9"],
            "newest first — the expanded list reads down into the past"
        )
    }

    @MainActor
    func testHoverExpandsOnlyTheFoldedBannerUnderTheCursor() {
        let queue = BannerQueue(capacity: 3, displayDuration: .seconds(3600), coalesceWindow: 10)
        queue.enqueue(NotificationEvent(id: "1", source: "s", title: "first", thread: "t"))
        queue.enqueue(NotificationEvent(id: "2", source: "s", title: "second", thread: "t"))
        queue.enqueue(NotificationEvent(id: "3", source: "a", title: "lonely"))

        queue.setHover(true, id: "1")
        XCTAssertTrue(queue.visible[0].expanded)
        XCTAssertFalse(queue.visible[1].expanded)

        queue.setHover(true, id: "3")
        XCTAssertFalse(queue.visible[0].expanded, "the fold collapses when the pointer leaves it")
        XCTAssertFalse(
            queue.visible[1].expanded,
            "a banner with nothing folded behind it stays the height it arrived at"
        )

        // Leaving the banner the pointer already left must not clear the
        // hover that a later enter took over.
        queue.setHover(true, id: "1")
        queue.setHover(false, id: "3")
        XCTAssertTrue(queue.visible[0].expanded, "a stale exit must not steal the live hover")
    }

    @MainActor
    func testDismissingTheHoveredBannerUnsticksTheQueue() {
        let queue = BannerQueue(capacity: 1, displayDuration: .seconds(3600))
        queue.enqueue(NotificationEvent(id: "1", source: "s", title: "first"))
        queue.enqueue(NotificationEvent(id: "2", source: "s", title: "second"))

        queue.setHover(true, id: "1")
        // Clicking the banner dismisses it out from under the pointer; no
        // exit event follows, so the queue has to clear the hover itself.
        queue.dismiss(id: "1")
        XCTAssertEqual(
            queue.visible.map(\.id), ["2"],
            "a hover left set would have paused the refill forever"
        )
    }
}
