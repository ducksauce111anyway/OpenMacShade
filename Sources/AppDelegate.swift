import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var overlayController: OverlayController!
    private var statusMenuController: StatusMenuController!

    func applicationDidFinishLaunching(_ notification: Notification) {
        overlayController = OverlayController()
        statusMenuController = StatusMenuController(overlayController: overlayController)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenParametersDidChange),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }

    func applicationWillTerminate(_ notification: Notification) {
        NotificationCenter.default.removeObserver(self)
        overlayController.cleanup()
    }

    @objc private func screenParametersDidChange(_ notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.overlayController.screenConfigurationDidChange()
        }
    }
}
