# Contributing

Thanks for considering a contribution to ScreenShade.

## Project Scope

ScreenShade should remain a tiny, easy-to-audit macOS app.

In scope:

- Swift + AppKit
- click-through black overlay dimming
- small reliability and safety fixes
- tests for overlay state management
- compatibility reports
- documentation improvements

Out of scope for the initial public release:

- network features
- analytics or telemetry
- automatic updates
- DDC/CI monitor control
- gamma table changes
- private APIs
- features requiring Accessibility permission
- global shortcuts
- login item support

## Development

Run tests:

```bash
swift test
```

Build the app bundle:

```bash
./build.sh
```

The app is ad-hoc signed for local testing. Developer ID signing and
notarization are not configured in this repository.

## Compatibility Reports

If ScreenShade works or fails on a device that is not listed as tested, please
open a device compatibility report and include the Mac model, chip, macOS
version, display setup, and result.
