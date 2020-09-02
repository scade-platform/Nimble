//
//  Generator.swift
//  
//
//  Created by Danil Kristalev on 25.08.2020.
//

import Cocoa

public class GeneratorsManager {
  public static let shared = GeneratorsManager()
  private var _generators: [Generator] = []
  
  public var generators: [Generator] {
    _generators.sorted{$0.name < $1.name}
  }
  
  public func register(resourceFactory: Generator) {
    guard !self.generators.contains(where: {$0.name == resourceFactory.name}) else { return }
    self._generators.append(resourceFactory)
  }
}

public protocol Generator {
  var icon: Icon? { get }
  var name: String { get }
  var wizardPages: [WizardPage] { get }

  func generate(onComplete: @escaping () -> Void)
}


public protocol WizardPage: NSView {
  var isValid: Bool { get }
  var validationHandler: (Bool) -> Void { get set }
  func clearPage()
}

