//
//  CreationWizard.swift
//  NimbleCore
//  
//  Copyright © 2021 SCADE Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
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

