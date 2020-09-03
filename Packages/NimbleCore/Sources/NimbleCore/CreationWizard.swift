//
//  CreationWizard.swift
//  
//
//  Created by Danil Kristalev on 25.08.2020.
//

import Cocoa

public class WizardsManager {
  public static let shared = WizardsManager()
  private var _wizards: [CreationWizard] = []
  
  public var wizards: [CreationWizard] {
    _wizards.sorted{$0.name < $1.name}
  }
  
  public func register(wizard: CreationWizard) {
    guard !self.wizards.contains(where: {$0.name == wizard.name}) else { return }
    self._wizards.append(wizard)
  }
}

public protocol CreationWizard {
  var icon: Icon? { get }
  var name: String { get }
  var wizardPages: [WizardPage] { get }

  func create(onComplete: @escaping () -> Void)
}


public protocol WizardPage: NSView {
  var isValid: Bool { get }
  var validationHandler: (Bool) -> Void { get set }
  func clearPage()
}

