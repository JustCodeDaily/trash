// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Trash",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(name: "Trash", path: "Sources/Trash"),
        .testTarget(name: "TrashTests", dependencies: ["Trash"], path: "Tests/TrashTests"),
    ]
)
