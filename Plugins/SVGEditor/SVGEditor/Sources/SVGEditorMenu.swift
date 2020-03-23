import Cocoa

open class SVGEditorMenu: NSObject {

  public weak var editor: SVGEditorViewProtocol? = nil

  public static let shared = SVGEditorMenu()
  
  public static let editorMenu: NSMenu = {
    let menu = NSMenu()
    menu.items = [
      NSMenuItem(title: "Zoom In",
                 action: #selector(zoomIn(_:)), keyEquivalent: "+"),

      NSMenuItem(title: "Zoom Out",
                 action: #selector(zoomOut(_:)), keyEquivalent: "-"),

      NSMenuItem(title: "Actual Size",
                 action: #selector(zoomActualSize(_:)), keyEquivalent: "o"),

      NSMenuItem(title: "Toggle Grid",
                 action: #selector(toggleGrid(_:)), keyEquivalent: "g"),

    ]

    menu.items.forEach {
      //$0.keyEquivalentModifierMask = .command
      $0.target = shared }
    
    return menu
  }()

  @objc func zoomIn(_ item: NSMenuItem) {
    SVGEditorMenu.shared.editor?.zoomIn()
  }

  @objc func zoomOut(_ item: NSMenuItem) {
    SVGEditorMenu.shared.editor?.zoomOut()
  }

  @objc func zoomActualSize(_ item: NSMenuItem) {
    SVGEditorMenu.shared.editor?.zoomActualSize()
  }

  @objc func toggleGrid(_ item: NSMenuItem) {
    SVGEditorMenu.shared.editor?.toggleGrid()
  }
}
