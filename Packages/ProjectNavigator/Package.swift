// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "ProjectNavigator",
    platforms: [
        .macOS(.v11),
    ],
    products: [
        // Make it dynamic if you want to share code with other plugins
        .library(name: "ProjectNavigator", targets: ["ProjectNavigator"]),
    ],
    dependencies: [
      .package(path: "../NimbleCore")
    ],
    targets: [
      .target(
        name: "ProjectNavigator",
        dependencies: [
          "NimbleCore"
        ]
      ),
    ]
)
