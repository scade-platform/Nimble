// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "FileIcons",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        // Make it dynamic if you want to share code with other plugins
      .library(name: "FileIcons", targets: ["FileIcons"]),
    ],
    dependencies: [
      .package(path: "../NimbleCore")
    ],
    targets: [
      .target(
        name: "FileIcons",
        dependencies: [
          "NimbleCore"
        ]
      ),
    ]
)
