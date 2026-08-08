import XCTest
@testable import Flick

final class ScreenGeometryTests: XCTestCase {
    // A 16:10 laptop with a menu bar carved off the top.
    private let laptop = ScreenDescriptor(
        id: "laptop",
        frame: CGRect(x: 0, y: 0, width: 1512, height: 982),
        visibleFrame: CGRect(x: 0, y: 0, width: 1512, height: 944)
    )

    // A second display positioned to the right in global coordinates.
    private let external = ScreenDescriptor(
        id: "external",
        frame: CGRect(x: 1512, y: 0, width: 2560, height: 1440),
        visibleFrame: CGRect(x: 1512, y: 0, width: 2560, height: 1415)
    )

    func testSlotsDealDownwardFromTopRightAsAStack() throws {
        let first = try XCTUnwrap(BannerGeometry.slotFrame(on: laptop, index: 0))
        let second = try XCTUnwrap(BannerGeometry.slotFrame(on: laptop, index: 1))

        XCTAssertEqual(first.maxX, laptop.visibleFrame.maxX - BannerGeometry.inset)
        XCTAssertEqual(first.maxY, laptop.visibleFrame.maxY - BannerGeometry.inset)
        XCTAssertEqual(
            second.maxY - first.minY, BannerGeometry.overlap,
            "cards tuck under one another — a deck, not a spaced list"
        )
        XCTAssertEqual(
            first.minX - second.minX, BannerGeometry.step,
            "each card deeper in the stack steps further left"
        )
    }

    func testSlotsStayInsideVisibleFrame() {
        for index in 0..<BannerGeometry.capacity(on: laptop) {
            guard let frame = BannerGeometry.slotFrame(on: laptop, index: index) else {
                return XCTFail("capacity promised slot \(index)")
            }
            XCTAssertTrue(
                laptop.visibleFrame.contains(frame),
                "slot \(index) escaped the visible frame"
            )
        }
    }

    func testIndexBeyondCapacityYieldsNoFrame() {
        let capacity = BannerGeometry.capacity(on: laptop)
        XCTAssertNil(BannerGeometry.slotFrame(on: laptop, index: capacity))
        XCTAssertNil(BannerGeometry.slotFrame(on: laptop, index: -1))
    }

    func testSecondaryDisplayUsesItsOwnGlobalOrigin() throws {
        let frame = try XCTUnwrap(BannerGeometry.slotFrame(on: external, index: 0))
        XCTAssertTrue(external.visibleFrame.contains(frame))
        XCTAssertGreaterThan(frame.minX, external.frame.minX)
    }

    func testTinyScreenReportsZeroCapacityInsteadOfOverflowing() {
        let tiny = ScreenDescriptor(
            id: "tiny",
            frame: CGRect(x: 0, y: 0, width: 400, height: 60),
            visibleFrame: CGRect(x: 0, y: 0, width: 400, height: 60)
        )
        XCTAssertEqual(BannerGeometry.capacity(on: tiny), 0)
        XCTAssertNil(BannerGeometry.slotFrame(on: tiny, index: 0))
    }

    // MARK: - Expanded folds

    func testCollapsedCardIsAlwaysTheBaseSize() {
        XCTAssertEqual(BannerGeometry.cardSize(foldedCount: 0, expanded: false), BannerGeometry.size)
        XCTAssertEqual(BannerGeometry.cardSize(foldedCount: 9, expanded: false), BannerGeometry.size)
        XCTAssertEqual(
            BannerGeometry.cardSize(foldedCount: 0, expanded: true), BannerGeometry.size,
            "hovering a banner with nothing folded behind it must not grow it"
        )
    }

    func testExpandedCardGrowsByExactlyItsFoldRows() {
        let two = BannerGeometry.cardSize(foldedCount: 2, expanded: true)
        XCTAssertEqual(two.width, BannerGeometry.size.width, "folds grow downward only")
        XCTAssertEqual(
            two.height,
            BannerGeometry.size.height + BannerGeometry.foldListInset + 2 * BannerGeometry.foldRowHeight
        )

        // Beyond the cap the tail collapses into one "and N earlier" row, so
        // a burst of 9 and a burst of 900 are the same height.
        let capped = BannerGeometry.foldRowCount(folded: 9)
        XCTAssertEqual(capped, BannerGeometry.maxFoldRows + 1)
        XCTAssertEqual(BannerGeometry.foldRowCount(folded: 900), capped)
    }

    func testExpandedCardPushesTheCardsBelowItDown() throws {
        let collapsed = BannerGeometry.cardSize(foldedCount: 3, expanded: false)
        let expanded = BannerGeometry.cardSize(foldedCount: 3, expanded: true)

        let flat = BannerGeometry.stackFrames(on: laptop, sizes: [collapsed, BannerGeometry.size])
        let grown = BannerGeometry.stackFrames(on: laptop, sizes: [expanded, BannerGeometry.size])

        let before = try XCTUnwrap(flat[1])
        let after = try XCTUnwrap(grown[1])
        XCTAssertEqual(before.maxY - after.maxY, expanded.height - collapsed.height)
        XCTAssertEqual(before.minX, after.minX, "growing a fold must not shift the stack sideways")
        XCTAssertEqual(try XCTUnwrap(grown[0]).size, expanded)
    }

    func testStackDropsEveryCardOnceItRunsOffTheScreen() {
        let shallow = ScreenDescriptor(
            id: "shallow",
            frame: CGRect(x: 0, y: 0, width: 1512, height: 200),
            visibleFrame: CGRect(x: 0, y: 0, width: 1512, height: 200)
        )
        let sizes = Array(repeating: BannerGeometry.size, count: 4)
        let frames = BannerGeometry.stackFrames(on: shallow, sizes: sizes)

        XCTAssertNotNil(frames[0])
        guard let firstMiss = frames.firstIndex(where: { $0 == nil }) else {
            return XCTFail("a 200pt screen cannot hold four banners")
        }
        XCTAssertTrue(
            frames[firstMiss...].allSatisfy { $0 == nil },
            "once the stack escapes it never comes back further down"
        )
    }
}
