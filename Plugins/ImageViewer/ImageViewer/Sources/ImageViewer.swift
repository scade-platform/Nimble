import NimbleCore

public final class ImageViewer: Module {
  public static var pluginClass: Plugin.Type = ImageViewerPlugin.self
}


open class ImageViewerPlugin: Plugin {
  required public init() {
    DocumentManager.shared.registerDocumentClass(ImageDocument.self)
  }
  
  public func activate(workbench: Workbench) {
    
  }
  
  public func deactivate() {
    
  }
}
