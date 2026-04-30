// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "neomouse",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        //SQLite toolkit
        .package(url: "https://github.com/groue/GRDB.swift.git", exact: "7.10.0")
    ],

    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "swift",
            dependencies: [
                .product(name: "GRDB", package: "GRDB.swift")
            ]
        ),
        .testTarget(
            name: "swiftTests",
            dependencies: ["swift"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
