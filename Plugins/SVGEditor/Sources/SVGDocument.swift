import AppKit
import NimbleCore
import ScadeKit
import SVGEditor

public final class SVGDocument: NimbleDocument, SVGDocumentProtocol {
  public var rootSvg: SCDSvgBox?

  public var svgWidth: SCDSvgUnit? { rootSvg?.width }
  
  public var svgHeight: SCDSvgUnit? { rootSvg?.height }

  lazy var documentController: EditorView = {
    let controller = EditorView.loadFromNib()
    controller.document = self

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
    rootSvg = SCDRuntime.parseSvg(url.path) as? SCDSvgBox
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
