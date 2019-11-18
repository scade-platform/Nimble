import AppKit
import NimbleCore

public final class ImageDocument: NSDocument{
  var image: NSImage?
  
  private lazy var builderController: ImageViewerController = {
    let controller = ImageViewerController.loadFromNib()
    controller.doc = self
    return controller
  }()
      
  public static func isDefault(for file: File) -> Bool {
    return canOpen(file)
  }
  
  public override func read(from data: Data, ofType typeName: String) throws {
    image = NSImage(data: data)
  }
  
  public override func data(ofType typeName: String) throws -> Data {
    return "".data(using: .utf8)!
  }
}


extension ImageDocument: Document {
  public var contentViewController: NSViewController? { return builderController }
  public static var typeIdentifiers: [String] { NSImage.imageTypes }
}
