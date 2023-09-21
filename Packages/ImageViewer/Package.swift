// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "ImageViewer",
    platforms: [
        .macOS(.v11),
    ],
    products: [
        // Make it dynamic if you want to share code with other plugins
        .library(name: "ImageViewer", targets: ["ImageViewer"]),
    ],
    dependencies: [
      .package(path: "../NimbleCore")
    ],
    targets: [
      .target(
        name: "ImageViewer",
        dependencies: [
          "NimbleCore"
        ]
      ),
    ]
)
