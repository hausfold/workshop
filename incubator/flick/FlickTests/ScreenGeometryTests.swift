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

    func testSlotsStackDownwardFromTopRight() throws {
        let first = try XCTUnwrap(BannerGeometry.slotFrame(on: laptop, index: 0))
        let second = try XCTUnwrap(BannerGeometry.slotFrame(on: laptop, index: 1))

        XCTAssertEqual(first.maxX, laptop.visibleFrame.maxX - BannerGeometry.inset)
        XCTAssertEqual(first.maxY, laptop.visibleFrame.maxY - BannerGeometry.inset)
        XCTAssertEqual(first.minY - second.maxY, BannerGeometry.spacing)
        XCTAssertEqual(first.minX, second.minX)
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
}
