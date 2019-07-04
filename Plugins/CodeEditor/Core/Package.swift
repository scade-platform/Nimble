// swift-tools-version:4.2

import PackageDescription

let package = Package(
  name: "CodeEditorCore",
  products: [
    .library(name: "CodeEditorCore", type: .dynamic, targets: ["CodeEditorCore"]),
  ],
  dependencies: [
    .package(path: "../../../Core"), // NimbleCore
    .package(url: "https://github.com/1024jp/WFColorCode.git", from: "2.5.0")
  ],
  targets: [
    .target(
      name: "CodeEditorCore",
      dependencies: ["NimbleCore", "ColorCode"]
    )
  ]
)
