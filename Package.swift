// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AdventOfCode",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "AdventOfCode",
            targets: ["AdventOfCode"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms.git", from: "0.0.2"),
    ],
    targets: [
        .target(
            name: "AdventOfCode",
            dependencies: []),
        .testTarget(
            name: "AdventOfCodeTests",
            dependencies: [
                "AdventOfCode",
                .product(name: "Algorithms", package: "swift-algorithms"),
            ],
            resources: [.process("resources")]),
    ])
