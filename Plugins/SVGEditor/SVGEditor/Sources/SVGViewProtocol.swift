import Cocoa
import ScadeKit
import ScadeKitExtension
import NimbleCore

public protocol SVGViewProtocol {

  var svgView: SVGView? { get }

  var elementSelector: SVGElementSelector { get }

  var sizeMultiplier: CGFloat { get }

  var doc: SVGDocumentProtocol? { get }

  func setupDocument() -> Void

  func createSVGView(for view: NSView) -> SVGView

  func setupSVGView() -> Void

  func setupElementSelector() -> Void
}

public extension SVGViewProtocol where Self: DocumentObserver {

  var sizeMultiplier: CGFloat { return 0.8 }

  func setupDocument() {
    doc?.observers.add(observer: self)
  }

  func createSVGView(for view: NSView) -> SVGView {
    let newSVGView = SVGView()
    
    view.addSubview(newSVGView)

    newSVGView.translatesAutoresizingMaskIntoConstraints = false

    newSVGView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    newSVGView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true


    newSVGView.widthAnchor.constraint(equalTo: view.widthAnchor,
                                   multiplier: sizeMultiplier).isActive = true
    newSVGView.heightAnchor.constraint(equalTo: view.heightAnchor,
                                    multiplier: sizeMultiplier).isActive = true

    return newSVGView
  }

  func setupSVGView() {
    if let rootSvg = doc?.rootSvg {
      svgView?.setSvg(rootSvg)
    }
    setupElementSelector()
  }

  func setupElementSelector() {
    if let rootSvg = doc?.rootSvg {
      elementSelector.process(rootSvg)
    }
  }
}
