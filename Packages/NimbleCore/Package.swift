// swift-tools-version:4.2

import PackageDescription

let package = Package(
  name: "NimbleCore",
  products: [
    .library(name: "NimbleCore", type: .dynamic, targets: ["NimbleCore"]),
  ],
  dependencies: [
    .package(url: "https://github.com/mxcl/Path.swift.git", from: "0.16.3"),
    .package(url: "https://github.com/jpsim/Yams.git", from: "2.0.0")
  ],
  targets: [
    .target(
      name: "NimbleCore",
      dependencies: ["Path", "Yams"]
    )
  ]
)
