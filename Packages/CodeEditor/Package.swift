// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "CodeEditor",    
    platforms: [
      .macOS(.v11),
    ],
    products: [        
      .library(name: "CodeEditor", type: .dynamic, targets: ["CodeEditor"]),
    ],
    dependencies: [
      .package(name: "NimbleCore", path: "../NimbleCore"),
      .package(url: "https://github.com/FLORG1/oniguruma.git", .branch("master"))
    ],
    targets: [
      .target(
        name: "CodeEditor",
        dependencies: [
          .product(name: "Oniguruma", package: "Oniguruma"),
          "NimbleCore"
        ]),
      .testTarget(
          name: "CodeEditorTests",
          dependencies: ["CodeEditor"]),
    ]
)
