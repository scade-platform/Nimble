import Cocoa
import ScadeKitExtension

class CanvasView: NSView {

  override var isFlipped: Bool { true }

  var isShowGrid = false

  private let svgSizeMultiplier = CGFloat(1.1)

  private let canvasMaxBound = CGFloat(2000)

  private let dotOffset = CGFloat(20)

  private let dotRadius = CGFloat(1)

  private let offset = CGFloat(100)

  private var xRulerOffset = CGFloat(0)

  private var yRulerOffset = CGFloat(0)

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

    xRulerOffset = svgX.truncatingRemainder(dividingBy: offset)
    yRulerOffset = svgY.truncatingRemainder(dividingBy: offset)

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

  override func draw(_ dirtyRect: NSRect) {
    if isShowGrid {
      
      if let context = NSGraphicsContext.current?.cgContext {
        context.setFillColor(NSColor.labelColor.cgColor)

        let minX = roundedGridValue(dirtyRect.minX, rule: .down) + xRulerOffset  - offset
        let maxX = roundedGridValue(dirtyRect.maxX, rule: .up)   + xRulerOffset
        let minY = roundedGridValue(dirtyRect.minY, rule: .down) + yRulerOffset  - offset
        let maxY = roundedGridValue(dirtyRect.maxY, rule: .up)   + yRulerOffset

        for x in stride(from: minX, to: maxX, by: offset) {
          drawVLine(context, y1: minY, y2: maxY, x: x)
        }

        for y in stride(from: minY, to: maxY, by: offset) {
          drawHLine(context, x1: minX, x2: maxX, y: y)
        }

        context.fillPath()
      }
    }

    super.draw(dirtyRect)
  }

  private func drawHLine(_ context: CGContext, x1:CGFloat, x2: CGFloat, y: CGFloat) {
    let rect = NSMakeRect(0, 0, dotRadius, dotRadius)

    for x in stride(from: x1, to: x2, by: dotOffset) {
      context.addEllipse(in: rect.offsetBy(dx: x - dotRadius, dy: y - dotRadius))
    }
  }

  private func drawVLine(_ context: CGContext, y1:CGFloat, y2: CGFloat, x: CGFloat) {
    let rect = NSMakeRect(0, 0, dotRadius, dotRadius)

    for y in stride(from: y1, to: y2, by: dotOffset) {
      context.addEllipse(in: rect.offsetBy(dx: x - dotRadius, dy :y - dotRadius))
    }
  }

  private func roundedGridValue(_ value: CGFloat, rule: FloatingPointRoundingRule) -> CGFloat{
    return (value / offset).rounded(rule) * offset
  }
}
