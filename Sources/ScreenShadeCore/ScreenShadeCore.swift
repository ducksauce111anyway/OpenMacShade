import Foundation

public enum ScreenShadeLimits {
    public static let minimumOpacity = 0.0
    public static let maximumOpacity = 0.85
    public static let defaultOpacity = 0.45

    public static func clampedOpacity(_ value: Double) -> Double {
        min(max(value, minimumOpacity), maximumOpacity)
    }
}

public struct ScreenShadePreferences {
    private enum Key {
        static let opacity = "ScreenShade.opacity"
    }

    private let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    public func loadOpacity() -> Double {
        guard userDefaults.object(forKey: Key.opacity) != nil else {
            return ScreenShadeLimits.defaultOpacity
        }
        return ScreenShadeLimits.clampedOpacity(userDefaults.double(forKey: Key.opacity))
    }

    public func saveOpacity(_ opacity: Double) {
        userDefaults.set(ScreenShadeLimits.clampedOpacity(opacity), forKey: Key.opacity)
    }
}

public final class OverlayStateController<Screen, Overlay> {
    public typealias ScreenProvider = () -> [Screen]
    public typealias OverlayFactory = (Screen, Double) -> Overlay
    public typealias OverlayCloser = (Overlay) -> Void
    public typealias OverlayOpacitySetter = (Overlay, Double) -> Void

    private let screenProvider: ScreenProvider
    private let overlayFactory: OverlayFactory
    private let overlayCloser: OverlayCloser
    private let overlayOpacitySetter: OverlayOpacitySetter

    public private(set) var opacity: Double
    public private(set) var isEnabled: Bool = false
    public private(set) var overlays: [Overlay] = []

    public init(
        initialOpacity: Double,
        screenProvider: @escaping ScreenProvider,
        overlayFactory: @escaping OverlayFactory,
        overlayCloser: @escaping OverlayCloser,
        overlayOpacitySetter: @escaping OverlayOpacitySetter
    ) {
        self.opacity = ScreenShadeLimits.clampedOpacity(initialOpacity)
        self.screenProvider = screenProvider
        self.overlayFactory = overlayFactory
        self.overlayCloser = overlayCloser
        self.overlayOpacitySetter = overlayOpacitySetter
    }

    public var overlayCount: Int {
        overlays.count
    }

    public func setOpacity(_ value: Double) {
        opacity = ScreenShadeLimits.clampedOpacity(value)
        overlays.forEach { overlayOpacitySetter($0, opacity) }
    }

    public func enable() {
        isEnabled = true
        rebuildOverlays()
    }

    public func disable() {
        isEnabled = false
        removeOverlays()
    }

    public func screenConfigurationDidChange() {
        if isEnabled {
            rebuildOverlays()
        } else {
            removeOverlays()
        }
    }

    public func cleanup() {
        disable()
    }

    public func rebuildOverlays() {
        removeOverlays()

        guard isEnabled else {
            return
        }

        overlays = screenProvider().map { screen in
            overlayFactory(screen, opacity)
        }
    }

    private func removeOverlays() {
        overlays.forEach { overlayCloser($0) }
        overlays.removeAll()
    }
}
