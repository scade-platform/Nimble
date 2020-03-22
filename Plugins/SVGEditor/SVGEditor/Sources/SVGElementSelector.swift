import ScadeKit
import ScadeKitExtension

public protocol SVGElementSelector {

  var svgView: SVGView? { get set}

  func process(_ element: SCDSvgElement)

  func onSelect(_ element: SCDSvgElement)

  func onUnselect(_ element: SCDSvgElement)
}

class SelectionView: NSView {

  override func hitTest(_ point: NSPoint) -> NSView? {
    let view = super.hitTest(point)

    return view === self ? nil : view
  }

}

open class SVGLayerSelector: SVGElementSelector, SVGElementVisitor {
  private weak var selected: SCDSvgElement?

  public weak var svgView: SVGView?

  let selectionBorderInset = CGFloat(6)

  lazy var selectView: SelectionView = {
    let view = SelectionView()
    view.wantsLayer = true
    view.layer?.backgroundColor = NSColor.clear.cgColor
    view.layer?.borderWidth = 3
    view.layer?.borderColor = NSColor.selectedControlColor.cgColor

    return view
  }()
  
  public init(_ svgView: SVGView) {
    self.svgView = svgView
  }

  public func process(_ element: SCDSvgElement) {
    visit(element)
  }

  public func apply(_ element: SCDSvgElement) {
    if let drawable = element as? SCDSvgDrawable {
      drawable.gestureRecognizers.append(
        SCDSvgTapGestureRecognizer(
          handler: { [unowned self] h in self.select(h?.target as! SCDSvgElement)} ))
    }
  }

  public func onUnselect(_ element: SCDSvgElement) {
    selectView.removeFromSuperview()
   }

  public func onSelect(_ element: SCDSvgElement) {
    guard let drawable = element as? SCDSvgDrawable else { return }

    let bbox = drawable.getBoundingBox()
    var frame = NSRect(x: bbox.location.x,
                       y: bbox.location.y,
                       width: bbox.bounds.width,
                       height: bbox.bounds.height)


    frame = frame.insetBy(dx: -selectionBorderInset,
                          dy: -selectionBorderInset)

    frame = frame.offsetBy(dx: svgView?.frame.origin.x ?? 0.0,
                           dy: svgView?.frame.origin.y ?? 0.0)

    selectView.frame = frame
    svgView?.superview?.addSubview(selectView, positioned: .above, relativeTo: nil)
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

  private func getLayerView(of element: SCDSvgElement) -> NSView? {
    return SCDRuntime.extract(intoLayer: element as! EObject)
  }
  
}

