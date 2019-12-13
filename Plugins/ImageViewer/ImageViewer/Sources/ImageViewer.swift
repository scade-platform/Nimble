import NimbleCore


public final class ImageViewer: Module {
  public static let plugin: Plugin = ImageViewerPlugin()
}


final class ImageViewerPlugin: Plugin {
  init() {
    DocumentManager.shared.registerDocumentClass(ImageDocument.self)
  }
}
