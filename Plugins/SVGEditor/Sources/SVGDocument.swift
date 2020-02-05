import AppKit
import NimbleCore
import ScadeKit

public final class SVGDocument: NimbleDocument {
  public var rootSvg: SCDSvgBox?

  private lazy var builderController: SVGEditorController = {
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
    let content = """
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:scade="http://www.scade.io/v0.1" contentScriptType="text/ecmascript" zoomAndPan="magnify" contentStyleType="text/css" preserveAspectRatio="xMidYMid meet" version="1.0">
      <image id="image" preserveAspectRatio="xMidYMid meet" width="100%" height="100%" xlink:href="\(url.path)"/>
      </svg>
      """
    
    rootSvg = SCDRuntime.parseSvgContent(content) as? SCDSvgBox
  }
  
  public override func data(ofType typeName: String) throws -> Data {
    return "".data(using: .utf8)!
  }
}

extension SVGDocument: Document {
  public var editor: WorkbenchEditor? { builderController }
  
  public static var typeIdentifiers: [String] = ["public.svg-image"]

  public static func isDefault(for file: File) -> Bool {
    return true
  }
}
