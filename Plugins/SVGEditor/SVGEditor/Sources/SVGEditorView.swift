import Cocoa
import NimbleCore
import ScadeKitExtension

open class SVGEditorView: NSViewController, SVGEditorViewProtocol {

  let sizeMultiplier: CGFloat = 0.8

  public var svgView = SVGView()

  public var elementSelector: SVGElementSelector! = nil

  public weak var doc: SVGDocumentProtocol? = nil
  
  open override func viewDidLoad() {
    super.viewDidLoad()

    setupDocument()
    setupScrollView()

    setupSVGViewConstraints()
    setupSVGView()
  }

  public func setupSVGView() {
    if let rootSvg = doc?.rootSvg {
      svgView.setSvg(rootSvg)
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

  private func setupSVGViewConstraints() {
    if let parentView = getScrollView() {
      
      svgView.translatesAutoresizingMaskIntoConstraints = false
      
      setPositionConstraint(for: svgView.leftAnchor, parentAnchor: parentView.leftAnchor)
      setPositionConstraint(for: svgView.topAnchor, parentAnchor: parentView.topAnchor)

      setDimensionConstraint(for: svgView.widthAnchor, svgUnit: doc?.svgWidth,
                             parentAnchor: parentView.widthAnchor)
      setDimensionConstraint(for: svgView.heightAnchor, svgUnit: doc?.svgHeight,
                             parentAnchor: parentView.heightAnchor)
    }
  }

  private func setupScrollView() {
    if let scrollView = getScrollView() {

      scrollView.documentView = svgView

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

extension SVGEditorView: WorkbenchEditor {
  public var editorMenu: NSMenu? {
    SVGEditorMenu.shared.editor = self

    return SVGEditorMenu.editorMenu
  }
}
