import ScadeKit

protocol WidgetSelector: WidgetVisitor {
  func onSelect(_ element: SCDSvgElement)

  func onUnselect(_ element: SCDSvgElement)
}

class SVGLayerSelector: WidgetSelector {
  private weak var selected: SCDSvgElement?

  public func apply(_ widget: SCDWidgetsWidget) {
    if let drawable = widget.drawing {
      drawable.gestureRecognizers.append(
        SCDSvgTapGestureRecognizer(
          handler: { [unowned self] h in self.select(h?.target as! SCDSvgElement)} ))
    }
  }

  public func onUnselect(_ element: SCDSvgElement) {
    getLayer(of: element)?.borderWidth = 0
  }

  public func onSelect(_ element: SCDSvgElement) {
    getLayer(of: element)?.borderWidth = 1
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

  private func getLayer(of element: SCDSvgElement) -> CALayer? {
    return SCDRuntime.extract(intoLayer: element as! EObject)?.layer
  }
  
}


