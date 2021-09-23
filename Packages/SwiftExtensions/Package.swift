// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SwiftExtensions",
    platforms: [
        .macOS(.v10_14),
    ],

    products: [        
        .library(name: "SwiftExtensions", type: .dynamic, targets: ["SwiftExtensions"]),
    ],

    dependencies: [
      .package(path: "../NimbleCore"),
      .package(path: "../CodeEditor"),
      .package(path: "../BuildSystem"),
      .package(path: "../LSPClient"),

      .package(name: "SwiftPM", url: "https://github.com/apple/swift-package-manager.git", .branch("release/5.3")),      
      .package(name: "SourceKitLSP", url: "https://github.com/FLORG1/sourcekit-lsp.git", .branch("release/5.3"))
    ],

    targets: [
      .target(
        name: "SwiftExtensions",
        dependencies: [
          "NimbleCore",
          "CodeEditor",
          "BuildSystem",
          "LSPClient",
          
          .product(name: "SwiftPM", package: "SwiftPM"),
          .product(name: "SourceKitLSP", package: "SourceKitLSP")          
        ],
        resources: [
          .process("Resources/swift-format")
        ]
      ),
    ]
)
