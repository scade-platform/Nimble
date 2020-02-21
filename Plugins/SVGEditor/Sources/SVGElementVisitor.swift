import ScadeKit

protocol SVGElementVisitor {
  func visit(_ element: SCDSvgElement)

  func apply(_ element: SCDSvgElement)
}

extension SVGElementVisitor {

  //TODO: add usage of the visitor of SVG elements from ScadeKit
  func visit(_ element: SCDSvgElement) {
    apply(element)

    if let contaner = element as? SCDSvgContainerElement {
      contaner.children.forEach { visit($0)}
    }
  }
}
