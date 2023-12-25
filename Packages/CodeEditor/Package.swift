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
      .package(url: "https://github.com/FLORG1/oniguruma.git", .revision("f8d6744efe50eb9aeb59d59e46d58979acf831d6"))
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
