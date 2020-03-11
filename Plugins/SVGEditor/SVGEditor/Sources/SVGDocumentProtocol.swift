import ScadeKit
import NimbleCore

public protocol SVGDocumentProtocol: Document {

  var rootSvg: SCDSvgBox? { get }

  var svgWidth: SCDSvgUnit? { get }

  var svgHeight: SCDSvgUnit? { get }
}
