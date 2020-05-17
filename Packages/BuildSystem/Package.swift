// swift-tools-version:5.2

import PackageDescription

let package = Package(
  name: "BuildSystem",
  platforms: [
    .macOS(.v10_14),
  ],
  products: [
    .library(name: "BuildSystem", type: .dynamic, targets: ["BuildSystem"]),
  ],
  dependencies: [
    .package(path: "../../NimbleCore"),
  ],
  targets: [
    .target(
      name: "BuildSystem",
      dependencies: ["NimbleCore"])
  ]
)
