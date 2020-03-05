import Cocoa

class EditorMenu: NSObject {

  weak var editor: EditorView? = nil

  static let shared = EditorMenu()
  
  static let editorMenu: NSMenu = {
    let menu = NSMenu()
    menu.items = [
      NSMenuItem(title: "Zoom In",
                 action: #selector(zoomIn(_:)), keyEquivalent: "+"),

      NSMenuItem(title: "Zoom Out",
                 action: #selector(zoomOut(_:)), keyEquivalent: "-"),

      NSMenuItem(title: "Actual Size",
                 action: #selector(actualSize(_:)), keyEquivalent: "o")
    ]

    menu.items.forEach {
      //$0.keyEquivalentModifierMask = .command
      $0.target = shared }
    
    return menu
  }()

  @objc func zoomIn(_ item: NSMenuItem) {
    EditorMenu.shared.editor?.zoomIn()
  }

  @objc func zoomOut(_ item: NSMenuItem) {
    EditorMenu.shared.editor?.zoomOut()
  }

  @objc func actualSize(_ item: NSMenuItem) {
    EditorMenu.shared.editor?.actualSize()
  }
  
}
