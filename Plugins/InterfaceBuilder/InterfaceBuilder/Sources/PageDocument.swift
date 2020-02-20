import AppKit
import NimbleCore
import ScadeKit

public final class PageDocument: NimbleDocument {
  private var resource: SCDCoreResource?

  public var rootSvg: SCDSvgBox? {
    return resource?.contents.last as? SCDSvgBox
  }

  public var page: SCDWidgetsPage? {
    return resource?.contents.first as? SCDWidgetsPage
  }

  private lazy var builderController: InterfaceBuilderView = {
    let controller = InterfaceBuilderView.loadFromNib()
    controller.doc = self

    return controller
  }()

  override public func presentedItemDidChange() {
    guard let url = self.fileURL, let type = self.fileType  else { return }

    DispatchQueue.main.async { [weak self] in
      try! self?.read(from: url, ofType: type)
      self?.onFileDidChange()
    }
  }
  
  public override func read(from url: URL, ofType typeName: String) throws {
    self.resource = SCDRuntime.loadXmiResource(url.path) as? SCDCoreResource
  }
  
  public override func data(ofType typeName: String) throws -> Data {
    return "".data(using: .utf8)!
  }
}

extension PageDocument: Document {
  public var editor: WorkbenchEditor? { builderController }
  
  /// TODO: register UTIs for the page files
  public static var typeIdentifiers: [String] = []
  
  public static func canOpen(_ file: File) -> Bool {
    return file.path.extension == "page"
  }
  
  public static func isDefault(for file: File) -> Bool {
    return canOpen(file)
  }
}
