//
//  SettingsController.swift
//  Scade
//
//  Created by Danil Kristalev on 23.08.2021.
//  Copyright © 2021 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore

class SettingsController {
  
  private weak var settingsDocument: Document? = nil
  private weak var workbench: Workbench?
  
  private var documentController: NimbleController? {
    NSDocumentController.shared as? NimbleController
  }
  
  func openSettingsEditor(in workbench: Workbench? = nil) {
    guard self.settingsDocument == nil else {
      //Settings have already opened
      return
    }
    
    guard let settingsDocument = openSettingDocument() else {
      return
    }
    
    self.settingsDocument = settingsDocument
    settingsDocument.observers.add(observer: self)
    
    if let content = Settings.shared.content.data(using: .utf8) {
      _ = try? settingsDocument.read(from: content, ofType: "public.text")
    }

    openEditor(in: workbench ?? documentController?.currentWorkbench)
  }
  
  private func openSettingDocument() -> Document? {
    
    guard let path = Settings.defaultPath else { return nil }

    if !path.exists {
      _ = try? path.touch()
    }

    guard let doc = DocumentManager.shared.open(path: path) else { return nil }
    return doc
  }
  
  private func openEditor(in workbench: Workbench?) {
    guard let settingsDocument = self.settingsDocument else {
      return
    }
    workbench?.observers.add(observer: self)
    workbench?.open(settingsDocument, show: true)
  }
  
  private func validateSettings() {
    guard let doc = settingsDocument else {
      return
    }
    
    let diagnostics = Settings.shared.validate()
    doc.editor?.publish(diagnostics: diagnostics)
    doc.editor?.workbench?.publish(diagnostics: diagnostics, for: .other("Settings"))
  }
}

// MARK: - DocumentObserver

extension SettingsController: DocumentObserver {
  func documentDidSave(_ document: Document) {
    guard let doc = settingsDocument, doc === document else { return }
    Settings.shared.reload()
    validateSettings()
  }
}

extension SettingsController: WorkbenchObserver {
  func workbenchDidOpenDocument(_ workbench: Workbench, document: Document) {
    guard settingsDocument === document  else {
      return
    }
    validateSettings()
  }
}
