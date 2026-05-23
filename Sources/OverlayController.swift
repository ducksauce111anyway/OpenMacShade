import AppKit
import ScreenShadeCore

final class OverlayController {
    static let maximumOpacity: Double = ScreenShadeLimits.maximumOpacity

    private let preferences: ScreenShadePreferences
    private let state: OverlayStateController<NSScreen, NSPanel>

    init() {
        preferences = ScreenShadePreferences()
        state = OverlayStateController<NSScreen, NSPanel>(
            initialOpacity: preferences.loadOpacity(),
            screenProvider: { NSScreen.screens },
            overlayFactory: Self.makeOverlayWindow,
            overlayCloser: Self.closeOverlayWindow,
            overlayOpacitySetter: Self.setOverlayWindowOpacity
        )
    }

    var opacity: Double {
        state.opacity
    }

    var isEnabled: Bool {
        state.isEnabled
    }

    func screenConfigurationDidChange() {
        state.screenConfigurationDidChange()
    }

    func cleanup() {
        state.cleanup()
    }

    func setOpacityFromSliderValue(_ value: Double) {
        state.setOpacity(value)
        preferences.saveOpacity(state.opacity)
    }

    func setEnabled(_ enabled: Bool) {
        if enabled {
            state.enable()
        } else {
            state.disable()
        }
    }

    private static func makeOverlayWindow(for screen: NSScreen, opacity: Double) -> NSPanel {
        let panel = NSPanel(
            contentRect: screen.frame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        panel.backgroundColor = .black
        panel.alphaValue = CGFloat(opacity)
        panel.isOpaque = false
        panel.hasShadow = false
        panel.ignoresMouseEvents = true
        panel.hidesOnDeactivate = false
        panel.level = .screenSaver
        panel.collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary,
            .stationary,
            .ignoresCycle
        ]
        panel.isReleasedWhenClosed = false
        panel.orderFrontRegardless()

        return panel
    }

    private static func closeOverlayWindow(_ window: NSPanel) {
        window.orderOut(nil)
        window.close()
    }

    private static func setOverlayWindowOpacity(_ window: NSPanel, opacity: Double) {
        window.alphaValue = CGFloat(opacity)
        window.orderFrontRegardless()
    }
}
