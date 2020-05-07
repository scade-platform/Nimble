import ScadeKit
import NimbleCore

public protocol SVGDocumentProtocol: Document {

  var rootSvg: SCDSvgBox? { get }

  var svgWidth: SCDSvgUnit? { get }

  var svgHeight: SCDSvgUnit? { get }

  func didOpen() -> Void
}

public extension SVGDocumentProtocol {

  func didOpen() {
    if let editor = self.editor as? SVGEditorViewProtocol {
      editor.didOpenDocument()
    }
  }
}
