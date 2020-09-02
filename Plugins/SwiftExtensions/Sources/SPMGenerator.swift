//
//  SPMGenerator.swift
//  SwiftExtensions.plugin
//
//  Created by Danil Kristalev on 02.09.2020.
//  Copyright © 2020 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore
import SwiftExtensions

class SPMGenerator: Generator {
  var icon: Icon? {
    nil
  }
  
  var name: String {
    "Swift Package"
  }
  
  var wizardPages: [WizardPage] = []
  
  func generate(onComplete: @escaping () -> Void) {
    let spmView = SPMGeneratorView.loadFromNib()
    let saveDialog = SPMSavePanel()
    saveDialog.nameFieldLabel = "Save As: "
    saveDialog.prompt = "Create"
    saveDialog.nameFieldStringValue = "MyLibrary"
    saveDialog.accessoryView = spmView
    saveDialog.beginSheetModal(for: NSApp.keyWindow!){ result in
      if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
        guard let directoryURL = saveDialog.directoryURL, let directoryPath = Path(url: directoryURL) else {
          onComplete()
          return
        }
        let projectName = saveDialog.nameFieldStringValue
        let projectPath = directoryPath/projectName
        
        //create project folder
        try? projectPath.mkdir()
        //generate SPM package
        let proc = Process()
        proc.currentDirectoryURL = projectPath.url
        let toolchain = SKLocalServer.swiftToolchain
        if !toolchain.isEmpty {
          proc.executableURL = URL(fileURLWithPath: "\(toolchain)/usr/bin/swift")
        } else {
          proc.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
        }
        
        let createGit = spmView.gitCheckBox!.state == .on
        let type = SPMProjectType(rawValue: spmView.typePopup!.selectedItem!.title)!
        proc.arguments = ["package", "init", "--type", type.commandType]
        //hide pacakge output
        proc.standardOutput = Pipe()
        proc.terminationHandler = {[weak self] _ in
          guard let self = self else { return }
          //If need to create git repo
           if createGit {
            let git = self.setupGit(location: projectPath)
            git(["init"])
            git(["add", "*"])
            git(["commit", "-m", "\"Initial Commit\""])
          }
          
          //open created folder in current workbench
          if let folder = Folder(path: projectPath) {
            DispatchQueue.main.async {
              NSApp.currentWorkbench?.project?.add(folder)
            }
          }
        }
        try? proc.run()
      }
      onComplete()
    }
    
  }
  
  func setupGit(location: Path) -> ([String]) -> Void {
    return { command in
      let proc = Process()
      proc.currentDirectoryURL = location.url
      proc.executableURL = URL(fileURLWithPath: "/usr/bin/git")
      proc.arguments = command
      //hide git output
      proc.standardOutput = Pipe()
      try? proc.run()
      proc.waitUntilExit()
    }
  }
  
  enum SPMProjectType: String {
    case library = "Library"
    case executable = "Executable"
    case empty = "Empty"
    case manifest = "Manifest"
    case systemModule = "System-module"
    
    var commandType: String {
      self.rawValue.prefix(1).lowercased() + self.rawValue.dropFirst()
    }
  }
}

private class SPMSavePanel: NSSavePanel {
  override var isExpanded: Bool {
    false
  }
}
