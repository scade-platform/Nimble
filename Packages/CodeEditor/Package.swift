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
      .package(path: "../NimbleCore"),
      .package(url: "https://github.com/FLORG1/oniguruma.git", .branch("master"))
    ],
    targets: [
      .target(
        name: "CodeEditor",
        dependencies: [
          .product(name: "Oniguruma", package: "oniguruma"),
          "NimbleCore"
        ]
      )
    ]
)
