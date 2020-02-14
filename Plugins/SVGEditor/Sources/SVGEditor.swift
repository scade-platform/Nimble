import NimbleCore
import ScadeKit

public final class SVGEditor: Module {
  public static let plugin: Plugin = SVGEditorPlugin()
}

final class SVGEditorPlugin: Plugin {
  init() {
    DocumentManager.shared.registerDocumentClass(SVGDocument.self)
    SCDRuntime.loadMetaModel()

    CommandManager.shared.registerCommand(command: Command(name: "Zoom In", menuPath: "View", keyEquivalent: "cmd+shift+") {SVGEditorPlugin.zoomIn()})

    CommandManager.shared.registerCommand(command: Command(name: "Zoom Out", menuPath: "View", keyEquivalent: "cmd+shift-") {SVGEditorPlugin.zoomOut()})
  }

  private static func zoomIn() {
    if let doc = currentSVGDocument() {
      doc.documentController.zoomIn()
    }
  }

  private static func zoomOut() {
    if let doc = currentSVGDocument() {
      doc.documentController.zoomOut()
    }
  }

  private static func currentSVGDocument() -> SVGDocument? {
    let workbench = NSDocumentController.shared.currentDocument?.windowForSheet?.windowController as? Workbench

    return workbench?.currentDocument as? SVGDocument
  }
}
