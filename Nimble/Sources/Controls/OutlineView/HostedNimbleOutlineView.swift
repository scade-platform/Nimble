//
//  HostedNimbleOutlineView.swift
//  Nimble
//
//  Created by Alex Yehorov on 05.10.2022.
//  Copyright © 2022 SCADE. All rights reserved.
//

import Cocoa
import NimbleCore
import SwiftUI

class HostedNimbleOutlineViewModel<Data: Sequence>: ObservableObject where Data.Element: Identifiable {
  @Published var data: Data
  
  init(data: Data) {
    self.data = data
  }
}

class HostedNimbleOutlineView: NSViewController, WorkbenchViewController {
  
  private var diagnostics: [(DiagnosticSource, Diagnostic)] = [] {
    didSet {
      let keyNameSet: Set<String> = Set(diagnostics.compactMap({ $0.0.string }))
      var result: [FileItem] = []
      keyNameSet.forEach { name in
        var errorMessages: [FileItem] = []
        diagnostics.forEach { (key, value) in
          if key.string == name {
            errorMessages.append(FileItem(name: value.message))
          }
        }
        result.append(FileItem(name: name, children: errorMessages))
      }
      
      model.data = result
    }
  }
  
  private var model = HostedNimbleOutlineViewModel(data: [FileItem]())
  
  override func loadView() {
    self.view = NSView()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let myView = NSHostingView(rootView: NimbleOutlineSwiftUIView(model: model))
    myView.translatesAutoresizingMaskIntoConstraints = false
    
    self.view.addSubview(myView)
    
    NSLayoutConstraint.activate([
      myView.topAnchor.constraint(equalTo: view.topAnchor),
      myView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      myView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      myView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
  
  override func viewDidAppear() {
    super.viewDidAppear()
    
    self.diagnostics = workbench?.diagnostics.flatMap({ diag in
      return diag.1.map{(diag.0, $0)}
    }) ?? []
    
    workbench?.observers.add(observer: self)
  }
}

extension HostedNimbleOutlineView: WorkbenchPart {
  var icon: NSImage? { return nil }
}

extension HostedNimbleOutlineView: WorkbenchObserver {
  func workbenchDidPublishDiagnostic(_ workbench: Workbench, diagnostic: [Diagnostic], source: DiagnosticSource) {
    diagnostics.removeAll { $0.0 == source }
    diagnostics.insert(contentsOf: diagnostic.map{(source, $0)}, at: 0)
  }
}
