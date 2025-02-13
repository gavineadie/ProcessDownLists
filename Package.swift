// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ProcessDownLists",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "ProcessDownLists"),
    ]
)
