// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ProcessDownLists",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0")
    ],
    targets: [
        .executableTarget(
            name: "ProcessDownLists",
            dependencies: [
                .product(name: "Logging", package: "swift-log",
                         condition: .when(platforms: [.linux]))
            ]),
    ]
)
