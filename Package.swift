// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ScreenShade",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .library(name: "ScreenShadeCore", targets: ["ScreenShadeCore"])
    ],
    targets: [
        .target(
            name: "ScreenShadeCore",
            path: "Sources/ScreenShadeCore"
        ),
        .testTarget(
            name: "ScreenShadeCoreTests",
            dependencies: ["ScreenShadeCore"],
            path: "Tests/ScreenShadeCoreTests"
        )
    ]
)
