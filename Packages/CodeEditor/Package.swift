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
        .package(path: "../../NimbleCore"),
        .package(url: "https://github.com/FLORG1/oniguruma.git", .branch("master")),
        .package(url: "https://github.com/1024jp/WFColorCode.git", from: "2.5.0")
    ],
    targets: [
        .target(name: "CodeEditor", dependencies: ["Oniguruma", "ColorCode", "NimbleCore"])
    ]
)
