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
        .package(url: "https://github.com/apple/swift-algorithms.git", from: "0.0.2"),
        .package(url: "https://github.com/jgriffin/ParserCombinator.git", from: "0.0.2"),
    ],
    targets: [
        .target(
            name: "AdventOfCode",
            dependencies: ["ParserCombinator"]
        ),
        .testTarget(
            name: "AdventOfCodeTests",
            dependencies: [
                "AdventOfCode",
                "ParserCombinator",
                .product(name: "Algorithms", package: "swift-algorithms"),
            ],
            resources: [.process("resources")]
        ),
    ]
)
