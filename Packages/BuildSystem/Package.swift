// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "BuildSystem",
  platforms: [
    .macOS(.v10_15),
  ],
  products: [
    .library(name: "BuildSystem", type: .dynamic, targets: ["BuildSystem"]),
  ],
  dependencies: [
    .package(path: "../NimbleCore"),
  ],
  targets: [
    .target(
      name: "BuildSystem",
      dependencies: ["NimbleCore"])
  ]
)
