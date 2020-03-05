import NimbleCore

public final class Editor: NimbleCore.Module {
  public static let plugin: NimbleCore.Plugin = Plugin()
}

final class Plugin: NimbleCore.Plugin {
  func load() {
    NimbleCore.DocumentManager.shared.registerDocumentClass(SVGDocument.self)
    ScadeKit.SCDRuntime.loadMetaModel()
  }
}
