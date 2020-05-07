import NimbleCore

public final class Editor: NimbleCore.Module {
  public static let plugin: NimbleCore.Plugin = Plugin()
}

final class Plugin: NimbleCore.Plugin {

  func load() {
    NimbleCore.DocumentManager.shared.registerDocumentClass(SVGDocument.self)
    ScadeKit.SCDRuntime.loadMetaModel()
  }

  public func activate(in workbench: Workbench) {
    workbench.observers.add(observer: self)
  }

  public func deactivate(in workbench: Workbench) {
    workbench.observers.remove(observer: self)
  }
}

extension Plugin: WorkbenchObserver {

  func workbenchDidOpenDocument(_ workbench: Workbench, document: Document) {
    if let svgDocument = document as? SVGDocument {
      svgDocument.didOpen()
    }
  }
}
