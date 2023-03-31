// swift-tools-version:5.1

import PackageDescription

let package = Package(
  name: "NimbleCore",
  platforms: [
    .macOS(.v10_15)
  ],
  products: [
    .library(name: "NimbleCore-deps", type: .dynamic, targets: ["Deps"]),
  ],
  dependencies: [
    .package(url: "https://github.com/mxcl/Path.swift.git", from: "0.16.3"),
    .package(url: "https://github.com/gr-markin/SwiftSVG", .branch("master")),
    .package(url: "https://github.com/1024jp/WFColorCode.git", .exact("2.8.0")),
  ],
  targets: [
    .target(
      name: "Deps",
      dependencies: ["Path", "SwiftSVG", "ColorCode"]
    )
  ]
)
