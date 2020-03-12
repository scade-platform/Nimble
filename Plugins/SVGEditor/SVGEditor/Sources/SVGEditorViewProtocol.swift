import Cocoa

public protocol SVGEditorViewProtocol: class {

  var scrollView: NSScrollView! { get }

  func zoomIn() -> Void

  func zoomOut() -> Void

  func zoomActualSize() -> Void
}

public extension SVGEditorViewProtocol {
  
  func zoomIn() {
    scrollView.magnification += 0.25
  }

  func zoomOut() {
    scrollView.magnification -= 0.25
  }

  func zoomActualSize() {
    scrollView.magnification = 1
  }
}

