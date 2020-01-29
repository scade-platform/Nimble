import NimbleCore
import ScadeKit

public final class SVGEditor: Module {
  public static let plugin: Plugin = SVGEditorPlugin()
}

final class SVGEditorPlugin: Plugin {
  init() {
    DocumentManager.shared.registerDocumentClass(SVGDocument.self)
    SCDRuntime.loadMetaModel()    
  }
}
