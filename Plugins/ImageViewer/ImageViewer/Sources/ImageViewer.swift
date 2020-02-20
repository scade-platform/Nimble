import NimbleCore


public final class ImageViewer: Module {
  public static let plugin: Plugin = ImageViewerPlugin()
}


final class ImageViewerPlugin: Plugin {
  func load() {
    DocumentManager.shared.registerDocumentClass(ImageDocument.self)
  }
}
