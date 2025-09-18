// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LLMCaller",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "LLMCaller",
            targets: ["LLMCaller"]),
    ],
    targets: [
        .target(
            name: "LLMCaller")
    ]
)
