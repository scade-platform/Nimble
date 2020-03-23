import Cocoa
import ScadeKitExtension

public class CanvasView: NSView {

  public override var isFlipped: Bool { true }

  var isShowGrid = false

  private let svgSizeMultiplier = CGFloat(1.1)

  private let canvasMaxBound = CGFloat(2000)

  private let dotOffset = CGFloat(10)

  private let dotRadius = CGFloat(1)

  private let offset = CGFloat(100)

  private var xRulerOffset = CGFloat(0)

  private var yRulerOffset = CGFloat(0)

  func didOpenDocument(_ doc: SVGDocumentProtocol?, svgView: SVGView) {
    guard let scrollView = enclosingScrollView else { return }

    //let screenSize = NSScreen.main?.frame.size

    let canvasWidth  = canvasMaxBound
    let canvasHeight = canvasMaxBound
    self.frame = NSMakeRect(0, 0, canvasWidth, canvasHeight)

    let contentView = scrollView.contentView
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

    scrollToCenter(affectRulers: scrollView.rulersVisible)
  }

  func zoomToFit() {
    guard let scrollView = self.enclosingScrollView,
          let svgView = self.subviews.first else { return }

    scrollView.magnify(toFit: svgView.bounds)
  }

  func scrollToCenter(affectRulers rulerFlag: Bool) {
    guard let scrollView = self.enclosingScrollView,
          let horizontalRulerView = scrollView.horizontalRulerView,
          let verticalRulerView = scrollView.verticalRulerView else { return }

    let magnification = scrollView.magnification
    let xRulerOffset = rulerFlag ? verticalRulerView.bounds.width    / magnification : 0
    let yRulerOffset = rulerFlag ? horizontalRulerView.bounds.height / magnification : 0
    let contentView = scrollView.contentView
    let newContentX = (self.bounds.width - contentView.bounds.size.width - xRulerOffset) / 2
    let newContentY = (self.bounds.height - contentView.bounds.size.height - yRulerOffset) / 2

    contentView.scroll(NSPoint(x: newContentX, y: newContentY))
    //scrollView.reflectScrolledClipView(contentView)
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

  public override func draw(_ dirtyRect: NSRect) {
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
    let radius = dotRadius / (enclosingScrollView?.magnification ?? 1.0)

    let rect = NSMakeRect(0, 0, radius, radius)

    for x in stride(from: x1, to: x2, by: dotOffset) {
      context.addEllipse(in: rect.offsetBy(dx: x - radius, dy: y - radius))
    }
  }

  private func drawVLine(_ context: CGContext, y1:CGFloat, y2: CGFloat, x: CGFloat) {
    let radius = dotRadius / (enclosingScrollView?.magnification ?? 1.0)

    let rect = NSMakeRect(0, 0, radius, radius)

    for y in stride(from: y1, to: y2, by: dotOffset) {
      context.addEllipse(in: rect.offsetBy(dx: x - radius, dy :y - radius))
    }
  }

  private func roundedGridValue(_ value: CGFloat, rule: FloatingPointRoundingRule) -> CGFloat{
    return (value / offset).rounded(rule) * offset
  }
}
