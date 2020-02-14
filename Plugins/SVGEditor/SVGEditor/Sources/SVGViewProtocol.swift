import ScadeKit
import ScadeKitExtension
import NimbleCore

public protocol SVGViewProtocol {

  var sizeMultiplier: CGFloat { get }

  var doc: SVGDocumentProtocol? { get }

  func setupDocument() -> Void

  func createElementSelector() -> SVGElementSelector

  func setupSVGView(for view: NSView) -> NSView
}

public extension SVGViewProtocol where Self: DocumentObserver {

  var sizeMultiplier: CGFloat { return 0.8 }

  func setupDocument() {
    doc?.observers.add(observer: self)
  }

  func setupSVGView(for view: NSView) -> NSView {
    let svgView = SVGView()
    svgView.setSvg(doc?.rootSvg)
    
    view.addSubview(svgView)

    svgView.translatesAutoresizingMaskIntoConstraints = false

    svgView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    svgView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true


    svgView.widthAnchor.constraint(equalTo: view.widthAnchor,
                                   multiplier: sizeMultiplier).isActive = true
    svgView.heightAnchor.constraint(equalTo: view.heightAnchor,
                                    multiplier: sizeMultiplier).isActive = true

    return svgView
  }
}
