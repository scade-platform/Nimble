// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "NimbleCore",
  platforms: [
    .macOS(.v11)
  ],
  products: [
    .library(name: "NimbleCore", type: .dynamic, targets: ["NimbleCore"]),
  ],
  dependencies: [
    .package(url: "https://github.com/mxcl/Path.swift.git", from: "0.16.3"),
    .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.0"),
    .package(url: "https://github.com/gr-markin/SwiftSVG", .branch("master")),
    .package(url: "https://github.com/1024jp/WFColorCode.git", .exact("2.8.0")),
    .package(url: "https://github.com/apple/swift-collections", .upToNextMajor(from: "1.0.0"))
  ],
  targets: [
    .target(
      name: "NimbleCore",
      dependencies: [
        .product(name: "Path", package: "Path.swift"),
        .product(name: "Yams", package: "Yams"),
        .product(name: "SwiftSVG", package: "SwiftSVG"),
        .product(name: "ColorCode", package: "WFColorCode"),
        .product(name: "Collections", package: "swift-collections")
      ]
    )
  ]
)
