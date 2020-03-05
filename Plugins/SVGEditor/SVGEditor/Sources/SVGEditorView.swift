import Cocoa
import NimbleCore
import ScadeKitExtension

open class SVGEditorView: NSViewController {

  let sizeMultiplier: CGFloat = 0.8

  public var svgView: SVGView? = nil

  public var elementSelector: SVGElementSelector! = nil

  public weak var doc: SVGDocumentProtocol? = nil
  
  open override func viewDidLoad() {
    super.viewDidLoad()

    setupDocument()

    svgView = createSVGView(for: view)
    setupSVGView()
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

  public func setupSVGView() {
    if let rootSvg = doc?.rootSvg {
      svgView?.setSvg(rootSvg)
    }
    setupElementSelector()
  }

  open func setupElementSelector() {
    if elementSelector == nil {
      elementSelector = SVGLayerSelector()
    }

    if let rootSvg = doc?.rootSvg {
      elementSelector.process(rootSvg)
    }
  }
}

extension SVGEditorView: DocumentObserver {

  func setupDocument() {
    doc?.observers.add(observer: self)
  }

  public func documentFileDidChange(_ document: Document) {
    setupSVGView()
  }
}

