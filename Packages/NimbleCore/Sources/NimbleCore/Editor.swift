import Cocoa

///TODO: avoid constraining the protocol to the NSViewController
public protocol WorkbenchEditor: NSViewController {
  ///TODO: replace by Commands
  // Shown within the app's main menu
  static var editorMenu: NSMenu? { get }

  var workbench: Workbench? { get }

  var statusBarItems: [WorkbenchStatusBarItem] { get }
  
  @discardableResult
  func focus() -> Bool
  
  func publish(diagnostics: [Diagnostic])
  
  func didOpenDocument(_ document: Document)
}


public extension WorkbenchEditor {
  static var editorMenu: NSMenu? { return nil }

  var workbench: Workbench? {
    return view.window?.windowController as? Workbench
  }

  var statusBarItems: [WorkbenchStatusBarItem] { return [] }
  
  func focus() -> Bool {
    return view.window?.makeFirstResponder(view) ?? false
  }
  
  func publish(diagnostics: [Diagnostic]) { }
  
  func didOpenDocument(_ document: Document) { }
}

// MARK: - Editor Command Actions

public protocol WorkbenchEditorZoomSupport where Self: WorkbenchEditor {
  func zoomIn()
  func zoomOut()
}



