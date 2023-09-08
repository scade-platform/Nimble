// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SwiftExtensions",
    platforms: [
        .macOS("11"),
    ],

    products: [
      .library(name: "SwiftExtensions", type: .dynamic, targets: ["SwiftExtensions"]),
    ],

    dependencies: [
      .package(path: "../NimbleCore"),
      .package(path: "../CodeEditor"),
      .package(path: "../BuildSystem"),
      .package(path: "../LSPClient"),
      
      .package(name: "SourceKitLSP", url: "https://github.com/FLORG1/sourcekit-lsp.git", .branch("release/5.8")),
    ],

    targets: [
      .target(
        name: "SwiftExtensions",
        dependencies: [
          "NimbleCore",
          "CodeEditor",
          "BuildSystem",
          "LSPClient",
          .product(name: "_SourceKitLSP", package: "SourceKitLSP")
        ],
        resources: [
          .process("Resources/lib_InternalSwiftSyntaxParser.dylib"),
          .process("Resources/swift-format")
        ]
      )
    ]
)
