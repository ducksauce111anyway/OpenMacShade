import AppKit

final class StatusMenuController: NSObject {
    private let overlayController: OverlayController
    private let statusItem: NSStatusItem
    private let menu = NSMenu()
    private let slider = NSSlider(
        value: 0.0,
        minValue: 0.0,
        maxValue: Double(OverlayController.maximumOpacity),
        target: nil,
        action: nil
    )
    private let valueLabel = NSTextField(labelWithString: "")
    private let toggleItem = NSMenuItem()

    init(overlayController: OverlayController) {
        self.overlayController = overlayController
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        super.init()

        configureStatusItem()
        configureMenu()
        refreshMenuState()
    }

    private func configureStatusItem() {
        if let button = statusItem.button {
            button.image = NSImage(
                systemSymbolName: "circle.lefthalf.filled",
                accessibilityDescription: "ScreenShade"
            )
            button.imagePosition = .imageOnly
        }
    }

    private func configureMenu() {
        menu.autoenablesItems = false

        let titleItem = NSMenuItem(title: "ScreenShade", action: nil, keyEquivalent: "")
        titleItem.isEnabled = false
        menu.addItem(titleItem)
        menu.addItem(.separator())

        let sliderContainer = NSView(frame: NSRect(x: 0, y: 0, width: 260, height: 54))

        let label = NSTextField(labelWithString: "Shade")
        label.frame = NSRect(x: 16, y: 29, width: 48, height: 18)
        sliderContainer.addSubview(label)

        valueLabel.alignment = .right
        valueLabel.frame = NSRect(x: 196, y: 29, width: 48, height: 18)
        sliderContainer.addSubview(valueLabel)

        slider.frame = NSRect(x: 16, y: 8, width: 228, height: 20)
        slider.target = self
        slider.action = #selector(sliderChanged(_:))
        slider.isContinuous = true
        sliderContainer.addSubview(slider)

        let sliderItem = NSMenuItem()
        sliderItem.view = sliderContainer
        menu.addItem(sliderItem)

        toggleItem.target = self
        toggleItem.action = #selector(toggleShade)
        menu.addItem(toggleItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(
            title: "Quit ScreenShade",
            action: #selector(quit),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    private func refreshMenuState() {
        slider.doubleValue = overlayController.opacity
        valueLabel.stringValue = "\(Int(round(overlayController.opacity * 100)))%"
        toggleItem.title = overlayController.isEnabled ? "Turn Off" : "Turn On"
    }

    @objc private func sliderChanged(_ sender: NSSlider) {
        overlayController.setOpacityFromSliderValue(sender.doubleValue)
        refreshMenuState()
    }

    @objc private func toggleShade() {
        overlayController.setEnabled(!overlayController.isEnabled)
        refreshMenuState()
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}
