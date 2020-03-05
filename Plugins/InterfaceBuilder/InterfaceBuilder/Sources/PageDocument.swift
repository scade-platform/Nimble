import AppKit
import NimbleCore
import ScadeKit
import SVGEditor

public final class PageDocument: NimbleDocument, SVGDocumentProtocol {
  private var resource: SCDCoreResource?

  public var rootSvg: SCDSvgBox? = nil

  public var page: SCDWidgetsPage? {
    return resource?.contents.first as? SCDWidgetsPage
  }

  private lazy var builderController: EditorView = {
    let controller = EditorView.loadFromNib()
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

    if let svgContent = resource?.contents.last {
      rootSvg = SCDRuntime.clone(svgContent) as? SCDSvgBox
    }
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
