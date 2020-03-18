import Cocoa
import ScadeKitExtension

class CanvasView: NSView {

  override var isFlipped: Bool { true }

  let svgSizeMultiplier = CGFloat(1.1)

  let canvasMaxBound = CGFloat(2000)

  func didOpenDocument(_ doc: SVGDocumentProtocol?,
                       scrollView: NSScrollView!, svgView: SVGView) {

    //let screenSize = NSScreen.main?.frame.size

    let canvasWidth  = canvasMaxBound
    let canvasHeight = canvasMaxBound
    self.frame = NSMakeRect(0, 0, canvasWidth, canvasHeight)

    let contentView = scrollView.contentView
    let contentViewOrigin = contentView.bounds.origin
    let contentViewSize = contentView.bounds.size

    let svgSize = svgDocumentSize(doc, contentSize: contentViewSize)
    let svgWidth  = svgSize.width
    let svgHeight = svgSize.height
    let svgX = (canvasWidth  - svgWidth)  / 2
    let svgY = (canvasHeight - svgHeight) / 2
    svgView.frame = NSMakeRect(svgX, svgY, svgWidth, svgHeight)

    scrollView.horizontalRulerView?.originOffset = svgX
    scrollView.verticalRulerView?.originOffset = svgY

    let resizeSvgWidth  = svgWidth  * svgSizeMultiplier
    let resizeSvgHeight = svgHeight * svgSizeMultiplier
    let resizeSvgX = (canvasWidth  - resizeSvgWidth) / 2
    let resizeSvgY = (canvasHeight - resizeSvgHeight) / 2
    scrollView.magnify(
      toFit: NSMakeRect(resizeSvgX, resizeSvgY, resizeSvgWidth, resizeSvgHeight))

    let magnification = scrollView.magnification
    let docViewOrigin = scrollView.documentVisibleRect.origin
    let newDocViewOriginX = docViewOrigin.x + contentViewOrigin.x * 0.5 / magnification
    let newDocViewOriginY = docViewOrigin.y + contentViewOrigin.y * 0.5 / magnification
    contentView.scroll(NSPoint(x: newDocViewOriginX, y: newDocViewOriginY))
    scrollView.reflectScrolledClipView(contentView)
  }

  private func svgDocumentSize(_ doc: SVGDocumentProtocol?, contentSize: NSSize) -> NSSize {
    return NSMakeSize(
      svgUnitValue(doc?.svgWidth, bound: contentSize.width),
      svgUnitValue(doc?.svgHeight, bound: contentSize.height)
    )
  }

  private func svgUnitValue(_ unit: SCDSvgUnit?, bound: CGFloat) -> CGFloat {
    guard let unit = unit else { return 1 }

    return CGFloat(unit.value) * (unit.measurement == .percentage ? bound * 0.01 : 1)
  }
}
