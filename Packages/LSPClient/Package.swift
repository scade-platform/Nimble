// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "LSPClient",
    platforms: [
        .macOS("10.15.4"),
    ],
    products: [        
        .library(name: "LSPClient", type: .dynamic, targets: ["LSPClient"]),
    ],
    dependencies: [
      .package(path: "../NimbleCore"),
      .package(path: "../BuildSystem"),
      .package(path: "../CodeEditor"),
            
      .package(name: "SourceKitLSP", url: "https://github.com/FLORG1/sourcekit-lsp.git", .branch("release/5.7"))
    ],
    targets: [
      .target(
        name: "LSPClient",
        dependencies: [
          "NimbleCore",
          "BuildSystem",
          "CodeEditor",
          .product(name: "_SourceKitLSP", package: "SourceKitLSP")
        ]
      ),
    ]
)
