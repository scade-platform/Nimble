//
//  BuildSystemFactory.swift
//  SwiftExtensions.plugin
//
//  Copyright © 2023 SCADE. All rights reserved.
//

import Foundation
import NimbleCore

public class SPMTargetModelFactory {

    private let folderURL: URL
    private let packageReader: SPMPackageReader

    private lazy var packageName: String = {
        folderURL.lastPathComponent
    }()

    init(folder url: URL) {
        self.folderURL = url
        self.packageReader = DefaultSPMPackageReader(folder: url)
    }

    func createBuildSystemModel() -> BuildSystemModel {

        let productsModel = createProductsModel()
        let targetsModel = createTargetsModel()

        //Target for whole package
        let packageTarget: BuildSystemModel = .element(SPMPackageBuildableModel(pathToPackage: folderURL))
        return .group(title: packageName,
                      elements: [
                        packageTarget,
                        .group(title: "Products", elements: [productsModel]),
                        .group(title: "Targets", elements: [targetsModel])
                      ])
    }

    private func createProductsModel() -> BuildSystemModel {
        createModel(from: packageReader.readProductsName(),
                    factoryMethod: { SPMProductBuildableModel(pathToPackage: $0, productName: $1)})
    }

    private func createTargetsModel() -> BuildSystemModel {
        createModel(from: packageReader.readTargetsName(),
                    factoryMethod: { SPMTargetBuildableModel(pathToPackage: $0, productName: $1) })
    }

    private func createModel(from names: [String], factoryMethod: (URL, String) -> SPMBuildableModel) -> BuildSystemModel {
        guard !names.isEmpty else {
            return .empty
        }

        let models: [BuildSystemModel] = names
            .map { factoryMethod(folderURL, $0) }
            .map { .element( $0 ) }

        return .section(elements: models)
    }
}

// MARK: - SPM Package Reader

public protocol SPMPackageReader {
    func readProductsName() -> [String]
    func readTargetsName() -> [String]
}

// MARK: - SPM Package Reader Default Implementation

public class DefaultSPMPackageReader: SPMPackageReader {
    private let folderURL: URL

    private lazy var packageDump: SPMPackageDump? = {
        let proc = ProcessBuilder(exec: "/usr/bin/swift")
                      .environment(key: "PATH", value: "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin")
                      .currentDirectory(path: self.folderURL.path)
                      .arguments("package", "dump-package")
                      .build()

        guard let packageJSONDump = try? proc.exec(), !packageJSONDump.isEmpty, let content = packageJSONDump.data(using: .utf8) else {
              return nil
        }
        let packageDump = try? JSONDecoder().decode(SPMPackageDump.self, from: content)
        return packageDump
    }()

    init(folder url: URL) {
        self.folderURL = url
    }

    public func readProductsName() -> [String] {
        guard let packageDump else {
            return []
        }
        return packageDump.products.map { $0.name }
    }

    public func readTargetsName() -> [String] {
        guard let packageDump else {
            return []
        }
        return packageDump.targets.map { $0.name }
    }
}

// MARK: - SPM Package Model

struct SPMPackageDump: Codable {
    var products: [SPMProductDump]
    var targets: [SPMTargetDump]
}

struct SPMProductDump: Codable {
    var name: String
}

struct SPMTargetDump: Codable {
    var name: String
}
