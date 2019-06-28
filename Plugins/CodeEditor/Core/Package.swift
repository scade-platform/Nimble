// swift-tools-version:4.2

import PackageDescription

let package = Package(
  name: "CodeEditorCore",
  products: [
    .library(name: "CodeEditorCore", type: .dynamic, targets: ["CodeEditorCore"]),
  ],
  dependencies: [
    .package(path: "../../../Core")
  ],
  targets: [
    .target(
      name: "CodeEditorCore",
      dependencies: ["NimbleCore"]
    )
  ]
)
