import Cocoa

public protocol SVGEditorViewProtocol: class {

  var scrollView: NSScrollView! { get }

  func zoomIn() -> Void

  func zoomOut() -> Void

  func zoomActualSize() -> Void

  func zoomToFit() -> Void

  func toggleGrid() -> Void

  func toggleShowRulers() -> Void
}

public extension SVGEditorViewProtocol {

  var canvasView: CanvasView? {
    return scrollView.documentView as? CanvasView
  }

  func zoomIn() {
    scrollView.magnification += 0.25
  }

  func zoomOut() {
    scrollView.magnification -= 0.25
  }

  func zoomToFit() {
    guard let canvasView = scrollView.documentView as? CanvasView else { return }

    canvasView.zoomToFit()
    canvasView.scrollToCenter(affectRulers: false)
  }

  func zoomActualSize() {
    guard let canvasView = scrollView.documentView as? CanvasView else { return }

    scrollView.magnification = 1
    canvasView.scrollToCenter(affectRulers: scrollView.rulersVisible)
  }

  func toggleGrid() {
    guard let canvasView = scrollView.documentView as? CanvasView else { return }

    canvasView.isShowGrid.toggle()
    canvasView.setNeedsDisplay(canvasView.bounds)
  }

  func toggleShowRulers() {
    scrollView.rulersVisible.toggle()
  }
}
