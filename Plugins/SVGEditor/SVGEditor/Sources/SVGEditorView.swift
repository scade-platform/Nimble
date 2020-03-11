import Cocoa
import NimbleCore
import ScadeKitExtension

open class SVGEditorView: NSViewController, SVGEditorViewProtocol {

  let sizeMultiplier: CGFloat = 0.8

  public var svgView: SVGView? = nil

  public var elementSelector: SVGElementSelector! = nil

  public weak var doc: SVGDocumentProtocol? = nil
  
  open override func viewDidLoad() {
    super.viewDidLoad()

    setupDocument()

    svgView = createSVGView(for: view)
    setupSVGView()

    getScrollView()?.documentView = svgView
    setupScrollView()
  }

  func createSVGView(for view: NSView) -> SVGView {
    let newSVGView = SVGView()
    
    view.addSubview(newSVGView)

    newSVGView.translatesAutoresizingMaskIntoConstraints = false
    
    setPositionConstraint(for: newSVGView.leftAnchor, parentAnchor: view.leftAnchor)
    setPositionConstraint(for: newSVGView.topAnchor, parentAnchor: view.topAnchor)

    setDimensionConstraint(for: newSVGView.widthAnchor, svgUnit: doc?.svgWidth,
                           parentAnchor: view.widthAnchor)
    setDimensionConstraint(for: newSVGView.heightAnchor, svgUnit: doc?.svgHeight,
                           parentAnchor: view.heightAnchor)

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

  open func getScrollView() -> NSScrollView? {
    return nil
  }

  public func zoomIn() {
    getScrollView()?.magnification += 0.25
  }

  public func zoomOut() {
    getScrollView()?.magnification -= 0.25
  }

  public func actualSize() {
    getScrollView()?.magnification = 1
  }

  private func setupScrollView() {
    if let scrollView = getScrollView() {
      scrollView.hasHorizontalRuler = true
      scrollView.hasVerticalRuler = true
      scrollView.rulersVisible = true
      
      scrollView.verticalScrollElasticity = .none
      scrollView.horizontalScrollElasticity = .none
      
      scrollView.borderType = .lineBorder
      
      scrollView.horizontalRulerView?.measurementUnits = .points
      scrollView.verticalRulerView?.measurementUnits = .points
      
      scrollView.allowsMagnification = true
      //scrollView.magnification = 10
    }
  }

  private func setPositionConstraint<T>(for anchor: NSLayoutAnchor<T>,
                                     parentAnchor: NSLayoutAnchor<T>) {
    anchor.constraint(equalTo: parentAnchor).isActive = true
  }

  private func setDimensionConstraint(for anchor: NSLayoutDimension,
                                      svgUnit: SCDSvgUnit?, parentAnchor: NSLayoutDimension) {
    guard let unit = svgUnit else { return }

    let value = CGFloat(unit.value)

    if unit.measurement == .percentage {
      anchor.constraint(equalTo: parentAnchor, multiplier: value * 0.01).isActive = true
    } else {
      anchor.constraint(equalToConstant: value).isActive = true
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

