import AppKit
import NimbleCore
import ScadeKit

public final class SVGDocument: NimbleDocument {
  public var rootSvg: SCDSvgBox?

  private lazy var documentController: SVGEditorController = {
    let controller = SVGEditorController.loadFromNib()
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
    if let svg = SCDRuntime.parseSvg(url.path) as? SCDSvgBox {

      //TODO: add usage of the visitor of SVG elements from ScadeKit
      //      and don't change the source of the svg document.
      svg.x = 0
      svg.y = 0
      svg.width = 100%
      svg.height = 100%

      rootSvg = svg
    }
  }
  
  public override func data(ofType typeName: String) throws -> Data {
    return "".data(using: .utf8)!
  }
}

extension SVGDocument: Document {
  public var editor: WorkbenchEditor? { documentController }
  
  public static var typeIdentifiers: [String] = ["public.svg-image"]

  public static func isDefault(for file: File) -> Bool {
    return true
  }
}
