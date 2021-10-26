// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "CodeEditor",    
    platforms: [
      .macOS(.v10_14),
    ],
    products: [        
      .library(name: "CodeEditor", type: .dynamic, targets: ["CodeEditor"]),
    ],
    dependencies: [
      .package(path: "../NimbleCore"),
      .package(url: "https://github.com/FLORG1/oniguruma.git", .branch("master"))
    ],
    targets: [
      .target(name: "CodeEditor", dependencies: ["Oniguruma", "NimbleCore"])
    ]
)
