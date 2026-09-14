// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "SlideFrame",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "SlideFrame", targets: ["SlideFrame"])
    ],
    targets: [
        .executableTarget(
            name: "SlideFrame",
            path: "SlideFrame",
            exclude: ["Assets.xcassets", "Info.plist"]
        ),
        .testTarget(
            name: "SlideFrameTests",
            dependencies: ["SlideFrame"],
            path: "SlideFrameTests"
        )
    ],
    swiftLanguageVersions: [.v5]
)
