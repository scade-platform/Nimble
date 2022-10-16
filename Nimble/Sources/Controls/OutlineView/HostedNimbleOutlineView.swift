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

let testData = [
    FileItem(name: "doc001.txt"),
    FileItem(
        name: "users",
        children: [
            FileItem(
                name: "user1234",
                children: [
                    FileItem(
                        name: "Photos",
                        children: [
                            FileItem(name: "photo001.jpg"),
                            FileItem(name: "photo002.jpg")]),
                    FileItem(
                        name: "Movies",
                        children: [FileItem(name: "movie001.mp4")]),
                    FileItem(name: "Documents", children: [])]),
            FileItem(
                name: "newuser",
                children: [FileItem(name: "Documents", children: [])])
        ]
    )
]

//@available(macOS 11.0, *)
class HostedNimbleOutlineView: NSViewController, WorkbenchViewController {
  
  private var diagnostics: [(DiagnosticSource, Diagnostic)] = [] {
    didSet {
      print(diagnostics)
      let test = diagnostics.compactMap({ FileItem(name: $0.1.message)})
      model.data = test
    }
  }
  
  private var model = HostedNimbleOutlineViewModel(data: [FileItem]())
  
  override func loadView() {
     self.view = NSView()
   }
    
  override func viewDidLoad() {
    super.viewDidLoad()
    
//    let model = HostedNimbleOutlineViewModel(data: modelData)
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

//@available(macOS 11.0, *)
extension HostedNimbleOutlineView: WorkbenchPart {
  var icon: NSImage? { return nil }
}

extension HostedNimbleOutlineView: WorkbenchObserver {
  func workbenchDidPublishDiagnostic(_ workbench: Workbench, diagnostic: [Diagnostic], source: DiagnosticSource) {
    diagnostics.removeAll { $0.0 == source }
    diagnostics.insert(contentsOf: diagnostic.map{(source, $0)}, at: 0)

//    table?.reloadData()
  }
}
