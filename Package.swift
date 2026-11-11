// swift-tools-version: 6.2
import PackageDescription

let mainActorByDefault: [SwiftSetting] = [.defaultIsolation(MainActor.self)]

let package = Package(
    name: "KeyboardSwitcher",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "KeyboardSwitcher", targets: ["KeyboardSwitcher"]),
        .executable(name: "keyboard-switcher-dev", targets: ["KeyboardSwitcherDevTool"]),
    ],
    targets: [
        .target(name: "KeyboardSwitcherCore"),
        .target(
            name: "KeyboardSwitcherKit",
            dependencies: ["KeyboardSwitcherCore"],
            swiftSettings: mainActorByDefault
        ),
        .target(
            name: "KeyboardSwitcherFakes",
            dependencies: ["KeyboardSwitcherKit", "KeyboardSwitcherCore"],
            swiftSettings: mainActorByDefault
        ),
        .executableTarget(
            name: "KeyboardSwitcher",
            dependencies: ["KeyboardSwitcherKit"],
            swiftSettings: mainActorByDefault
        ),
        .executableTarget(
            name: "KeyboardSwitcherDevTool",
            dependencies: ["KeyboardSwitcherKit", "KeyboardSwitcherFakes", "KeyboardSwitcherCore"],
            swiftSettings: mainActorByDefault
        ),
        .testTarget(
            name: "KeyboardSwitcherCoreTests",
            dependencies: ["KeyboardSwitcherCore"]
        ),
        .testTarget(
            name: "KeyboardSwitcherKitTests",
            dependencies: ["KeyboardSwitcherKit", "KeyboardSwitcherFakes", "KeyboardSwitcherCore"],
            swiftSettings: mainActorByDefault
        ),
    ]
)
