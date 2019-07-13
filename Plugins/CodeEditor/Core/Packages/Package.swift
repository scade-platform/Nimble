// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "Packages",
    dependencies: [
        .package(url: "https://github.com/1024jp/WFColorCode.git", from: "2.5.0")
    ],
    targets: [
        .target(name: "Packages", dependencies: ["ColorCode"], path: ".")
    ]
)
