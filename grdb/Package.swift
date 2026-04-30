// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "GRDBDemo",
    platforms: [.macOS(.v10_15)],
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift.git", exact: "7.10.0"),
    ],
    targets: [
        .executableTarget(
            name: "GRDBDemo",
            dependencies: [
                .product(name: "GRDB", package: "GRDB.swift"),
            ]
        ),
        .testTarget(
            name: "GRDBDemoTests",
            dependencies: [
                "GRDBDemo",
                .product(name: "GRDB", package: "GRDB.swift"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
