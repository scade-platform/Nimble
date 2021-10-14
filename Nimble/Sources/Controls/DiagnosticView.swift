//
//  DiagnosticsView.swift
//  Nimble
//
//  Copyright © 2021 SCADE Inc. All rights reserved.
//
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
import NimbleCore


class DiagnosticView: NSViewController, WorkbenchViewController {
  @IBOutlet weak var table: NSTableView? = nil

  private var diagnostics: [(DiagnosticSource, Diagnostic)] = [] {
    didSet {
      table?.reloadData()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    table?.delegate = self
    table?.dataSource = self
  }

  override func viewDidAppear() {
    super.viewDidAppear()

    self.diagnostics = workbench?.diagnostics.flatMap({ diag in
      return diag.1.map{(diag.0, $0)}
    }) ?? []

    workbench?.observers.add(observer: self)
  }
}

extension DiagnosticView: WorkbenchPart {
  var icon: NSImage? { return nil }
}


extension DiagnosticView: WorkbenchObserver {
  func workbenchDidPublishDiagnostic(_ workbench: Workbench, diagnostic: [Diagnostic], source: DiagnosticSource) {
    diagnostics.removeAll { $0.0 == source }
    diagnostics.insert(contentsOf: diagnostic.map{(source, $0)}, at: 0)

    table?.reloadData()
  }
}

extension DiagnosticView: NSTableViewDataSource {
  func numberOfRows(in tableView: NSTableView) -> Int {
    return diagnostics.count
  }
}


extension DiagnosticView: NSTableViewDelegate {
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    let item = diagnostics[row]

    var cell: NSTableCellView? = nil
    if tableColumn == tableView.tableColumns[0] {
      cell = tableView.makeCell(id: "IconCell")

      switch item.1.severity {
      case .error:
        cell?.imageView?.image = IconsManager.Icons.error.image
      case .warning:
        cell?.imageView?.image = IconsManager.Icons.warning.image
      default:
        break
      }



    } else if tableColumn == tableView.tableColumns[1] {
      cell = tableView.makeCell(id: "MessageCell")
      cell?.textField?.stringValue = item.1.message

    } else if tableColumn == tableView.tableColumns[2] {
      cell = tableView.makeCell(id: "SourceCell")
      switch item.0 {
      case .path(let path):
        guard let projectPath = workbench?.project?.path else { fallthrough }
        cell?.textField?.stringValue = path.relative(to: projectPath)
      default:
        cell?.textField?.stringValue = item.0.string
      }

    }

    cell?.identifier = nil
    cell?.textField?.isEnabled = false

    return cell
  }
}


//MARK: - CompletionIconView

class IconCellView: NSTableCellView {
  @IBOutlet weak var iconView: NSImageView! = nil
}
