import ScadeKit
import NimbleCore

public protocol SVGDocumentProtocol: Document {

  var rootSvg: SCDSvgBox? { get }
}
