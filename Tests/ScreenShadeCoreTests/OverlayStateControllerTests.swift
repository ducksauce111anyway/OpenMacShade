import Foundation
import XCTest
@testable import ScreenShadeCore

private struct FakeScreen: Equatable {
    let id: Int
}

private final class FakeOverlay {
    let screen: FakeScreen
    var opacity: Double
    var isClosed = false

    init(screen: FakeScreen, opacity: Double) {
        self.screen = screen
        self.opacity = opacity
    }
}

final class OverlayStateControllerTests: XCTestCase {
    func testCreatesNoOverlaysForZeroScreens() {
        let harness = Harness(screens: [])
        harness.controller.enable()

        XCTAssertTrue(harness.controller.isEnabled)
        XCTAssertEqual(harness.controller.overlayCount, 0)
    }

    func testCreatesOneOverlayForOneScreen() {
        let harness = Harness(screens: [FakeScreen(id: 1)])
        harness.controller.enable()

        XCTAssertEqual(harness.controller.overlayCount, 1)
        XCTAssertEqual(harness.controller.overlays.first?.screen, FakeScreen(id: 1))
    }

    func testCreatesTwoOverlaysForTwoScreens() {
        let harness = Harness(screens: [FakeScreen(id: 1), FakeScreen(id: 2)])
        harness.controller.enable()

        XCTAssertEqual(harness.controller.overlayCount, 2)
    }

    func testCreatesThreeOverlaysForThreeScreens() {
        let harness = Harness(screens: [FakeScreen(id: 1), FakeScreen(id: 2), FakeScreen(id: 3)])
        harness.controller.enable()

        XCTAssertEqual(harness.controller.overlayCount, 3)
    }

    func testScreenConfigurationChangeClosesOldOverlaysAndRebuilds() {
        let harness = Harness(screens: [FakeScreen(id: 1), FakeScreen(id: 2)])
        harness.controller.enable()
        let oldOverlays = harness.controller.overlays

        harness.screens = [FakeScreen(id: 3)]
        harness.controller.screenConfigurationDidChange()

        XCTAssertEqual(harness.controller.overlayCount, 1)
        XCTAssertEqual(harness.controller.overlays.first?.screen, FakeScreen(id: 3))
        XCTAssertTrue(oldOverlays.allSatisfy(\.isClosed))
    }

    func testDisableClosesAllOverlays() {
        let harness = Harness(screens: [FakeScreen(id: 1), FakeScreen(id: 2)])
        harness.controller.enable()
        let oldOverlays = harness.controller.overlays

        harness.controller.disable()

        XCTAssertFalse(harness.controller.isEnabled)
        XCTAssertEqual(harness.controller.overlayCount, 0)
        XCTAssertTrue(oldOverlays.allSatisfy(\.isClosed))
    }

    func testCleanupClosesAllOverlays() {
        let harness = Harness(screens: [FakeScreen(id: 1), FakeScreen(id: 2)])
        harness.controller.enable()
        let oldOverlays = harness.controller.overlays

        harness.controller.cleanup()

        XCTAssertFalse(harness.controller.isEnabled)
        XCTAssertEqual(harness.controller.overlayCount, 0)
        XCTAssertTrue(oldOverlays.allSatisfy(\.isClosed))
    }

    func testOpacityIsClampedToSafeRange() {
        let harness = Harness(screens: [FakeScreen(id: 1)], initialOpacity: 9.0)

        XCTAssertEqual(harness.controller.opacity, ScreenShadeLimits.maximumOpacity)

        harness.controller.setOpacity(-1.0)
        XCTAssertEqual(harness.controller.opacity, ScreenShadeLimits.minimumOpacity)

        harness.controller.setOpacity(0.42)
        XCTAssertEqual(harness.controller.opacity, 0.42)
    }

    func testOpacityChangesAreAppliedToExistingOverlays() {
        let harness = Harness(screens: [FakeScreen(id: 1)])
        harness.controller.enable()

        harness.controller.setOpacity(0.7)

        XCTAssertEqual(harness.controller.overlays.first?.opacity, 0.7)
    }

    func testStartupIsAlwaysOffWhileSavedOpacityIsRestored() {
        let suiteName = "ScreenShadeTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        let preferences = ScreenShadePreferences(userDefaults: defaults)
        preferences.saveOpacity(0.72)

        let harness = Harness(screens: [FakeScreen(id: 1)], initialOpacity: preferences.loadOpacity())

        XCTAssertFalse(harness.controller.isEnabled)
        XCTAssertEqual(harness.controller.overlayCount, 0)
        XCTAssertEqual(harness.controller.opacity, 0.72)

        defaults.removePersistentDomain(forName: suiteName)
    }
}

private final class Harness {
    private let screenBox: ScreenBox
    let controller: OverlayStateController<FakeScreen, FakeOverlay>

    var screens: [FakeScreen] {
        get { screenBox.screens }
        set { screenBox.screens = newValue }
    }

    init(screens: [FakeScreen], initialOpacity: Double = ScreenShadeLimits.defaultOpacity) {
        let screenBox = ScreenBox(screens)
        self.screenBox = screenBox
        controller = OverlayStateController<FakeScreen, FakeOverlay>(
            initialOpacity: initialOpacity,
            screenProvider: { screenBox.screens },
            overlayFactory: { screen, opacity in
                FakeOverlay(screen: screen, opacity: opacity)
            },
            overlayCloser: { overlay in
                overlay.isClosed = true
            },
            overlayOpacitySetter: { overlay, opacity in
                overlay.opacity = opacity
            }
        )
    }
}

private final class ScreenBox {
    var screens: [FakeScreen]

    init(_ screens: [FakeScreen]) {
        self.screens = screens
    }
}
