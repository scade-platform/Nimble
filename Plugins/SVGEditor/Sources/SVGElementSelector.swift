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

protocol SVGElementSelector: SVGElementVisitor {
  func onSelect(_ element: SCDSvgElement)

  func onUnselect(_ element: SCDSvgElement)
}

class SVGLayerSelector: SVGElementSelector {
  private weak var selected: SCDSvgElement?

  public func apply(_ element: SCDSvgElement) {
    if let drawable = element as? SCDSvgDrawable {
      drawable.gestureRecognizers.append(
        SCDSvgTapGestureRecognizer(
          handler: { [unowned self] h in self.select(element)} ))
    }
  }

  public func onUnselect(_ element: SCDSvgElement) {
    Swift.print("unselect: \(element.id)")
  }

  public func onSelect(_ element: SCDSvgElement) {
    Swift.print("select: \(element) \(element.id)")
  }

  private func select(_ element: SCDSvgElement) {
    if let oldSelected = selected {
      if !(oldSelected === element) {
        onUnselect(oldSelected)
        doSelect(element)
      }
    } else {
      doSelect(element)
    }
  }

  private func doSelect(_ element: SCDSvgElement) {
    onSelect(element)
    selected = element
  }
  
}

