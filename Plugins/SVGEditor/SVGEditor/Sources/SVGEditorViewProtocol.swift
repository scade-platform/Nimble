import Cocoa

public protocol SVGEditorViewProtocol: class {

  func getScrollView() -> NSScrollView?

  func zoomIn() -> Void

  func zoomOut() -> Void

  func zoomActualSize() -> Void
}

public extension SVGEditorViewProtocol {
  
  func zoomIn() {
    getScrollView()?.magnification += 0.25
  }

  func zoomOut() {
    getScrollView()?.magnification -= 0.25
  }

  func zoomActualSize() {
    getScrollView()?.magnification = 1
  }
}

