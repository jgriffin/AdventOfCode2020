// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AdventOfCode",
    products: [
        .library(
            name: "AdventOfCode",
            targets: ["AdventOfCode"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms.git", from: "0.2.1"),
        .package(url: "https://github.com/jgriffin/ParserCombinator.git", from: "0.0.3"),
        .package(url: "https://github.com/jgriffin/EulerTools.git", from: "0.1.0"),
    ],
    targets: [
        .target(
            name: "AdventOfCode",
            dependencies: [
                "ParserCombinator",
                .product(name: "Algorithms", package: "swift-algorithms"),
            ]
        ),
        .testTarget(
            name: "AdventOfCodeTests",
            dependencies: [
                "AdventOfCode",
                "ParserCombinator",
                "EulerTools",
                .product(name: "Algorithms", package: "swift-algorithms"),
            ],
            resources: [.process("resources")]
        ),
    ]
)
