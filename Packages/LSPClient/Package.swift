// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "LSPClient",
    platforms: [
        .macOS(.v10_14),
    ],
    products: [        
        .library(name: "LSPClient", type: .dynamic, targets: ["LSPClient", "SKLocalServer"]),
    ],
    dependencies: [
      .package(path: "../../NimbleCore"),
      .package(path: "../CodeEditor"),
      .package(url: "https://github.com/FLORG1/sourcekit-lsp.git", .branch("swift-5.2-branch")),
    ],
    targets: [
      .target(
        name: "LSPClient",
        dependencies: [
          "NimbleCore",
          "CodeEditor",
          "SourceKitLSP"
        ]
      ),
      .target(
        name: "SKLocalServer",
        dependencies: [
          "NimbleCore",
          "LSPClient",
          "SourceKitLSP"
        ]
      )
    ]
)
