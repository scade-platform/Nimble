import Cocoa
import NimbleCore

class ZoomCommand : Command {

  override func validate(in workbench: Workbench) -> State {
    return workbench.currentDocument?.editor is WorkbenchEditorZoomSupport ? .default : .disabled
  }

  static func create(name: String , keyEquivalent: String,
                     handler: @escaping (WorkbenchEditorZoomSupport) -> Void) -> Command {
    let command = ZoomCommand(name: name, keyEquivalent: keyEquivalent) { workbench in
      guard let editor = workbench.currentDocument?.editor as? WorkbenchEditorZoomSupport else { return }
      handler(editor)
    }
    return command
  }
}

class ZoomToFitCommand : Command {

  override func validate(in workbench: Workbench) -> State {
    return workbench.currentDocument?.editor is WorkbenchEditorZoomToFitSupport ? .default : .disabled
  }

  static func create(name: String , keyEquivalent: String,
                     handler: @escaping (WorkbenchEditorZoomToFitSupport) -> Void) -> Command {
    let command = ZoomCommand(name: name, keyEquivalent: keyEquivalent) { workbench in
      guard let editor = workbench.currentDocument?.editor as? WorkbenchEditorZoomToFitSupport else { return }
      handler(editor)
    }
    return command
  }
}

