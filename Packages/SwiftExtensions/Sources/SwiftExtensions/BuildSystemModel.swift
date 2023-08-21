//
//  BuildSystemModel.swift
//  SwiftExtensions.plugin
//
//  Copyright © 2023 SCADE. All rights reserved.
//

import Foundation
import BuildSystem


// MARK: - BuildSystemModel
enum BuildSystemModel {
    case empty
    case element(SwiftBuildableModel)
    indirect case group(title: String, elements: [BuildSystemModel])
    indirect case section(elements: [BuildSystemModel])
}

extension BuildSystemModel: CustomStringConvertible {
    public var description: String {
        switch self {
        case .empty:
            return "<Empty>"
        case .element(let model):
            return "\(model.kind)"
        case .group(let title, let elements):
            let descriptions = elements.map(\.description)
            return "\n\(title)\n\t\t\(descriptions.joined(separator: ""))"
        case .section(let elements):
            let descriptions = elements.map(\.description)
            return "\n<SECTION>\(descriptions.joined(separator: "")) \n<\\SECTION>"
        }
    }
}

extension BuildSystemModel {
    func createVariants(for target: SPMTarget) -> [Variant] {
        switch self {
        case .empty:
            return []
        case .element(let swiftBuildableModel):
            return [BuildSystemModelVariant(target: target, model: swiftBuildableModel)]
        case .group(_, let elements):
            let variants = elements.flatMap { $0.createVariants(for: target) }
            return variants
        case .section(let elements):
            let variants = elements.flatMap { $0.createVariants(for: target) }
            return variants
        }
    }
}

// MARK: - Kind
enum SwiftBuildableKind {

    case spm(productName: String)
    case singleFile(fileName: String)

    public var title: String {
        switch self {
        case .spm(let productName):
            return productName
        case .singleFile(let fileName):
            return fileName
        }
    }
}

// MARK: - Target Models
class SwiftBuildableModel {
    public let kind: SwiftBuildableKind

    var buildCommandArguments: [String] { [] }

    var title: String {
        kind.title
    }

    init(kind: SwiftBuildableKind) {
        self.kind = kind
    }
    
}

class SPMBuildableModel: SwiftBuildableModel {
    var pathToPackage: URL
    var productName: String

    init(pathToPackage: URL, productName: String) {
        self.pathToPackage = pathToPackage
        self.productName = productName
        super.init(kind: .spm(productName: productName))
    }
}

class SPMProductBuildableModel: SPMBuildableModel {
    override var buildCommandArguments: [String] {
        ["build", "--product", "\(productName)"]
    }
}

class SPMTargetBuildableModel: SPMBuildableModel {
    override var buildCommandArguments: [String] {
        ["build", "--target", "\(productName)"]
    }
}

class SPMPackageBuildableModel: SPMBuildableModel {
    init(pathToPackage: URL, packageName: String = "All Products") {
        super.init(pathToPackage: pathToPackage, productName: packageName)
    }

    override var buildCommandArguments: [String] {
        ["build"]
    }
}

