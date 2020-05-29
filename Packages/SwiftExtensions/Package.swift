// swift-tools-version:5.1

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
      .package(path: "../../NimbleCore"),
      .package(path: "../../BuildSystem"),
      .package(path: "../../LSPClient"),
      
      .package(url: "https://github.com/FLORG1/sourcekit-lsp.git", .branch("swift-5.2-branch")),
    ],
    targets: [
      .target(
        name: "SwiftExtensions",
        dependencies: [
          "NimbleCore",
          "BuildSystem",
          "LSPClient",
          "SourceKitLSP"
        ]
      ),
    ]
)
