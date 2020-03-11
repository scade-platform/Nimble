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

    getScrollView()?.scroll(BackgroundView.center())
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
    if let contentView = getScrollView()?.contentView,
       let documentView = getScrollView()?.documentView {

      documentView.translatesAutoresizingMaskIntoConstraints = false

      setPositionConstraint(for: documentView.leftAnchor, refAnchor: contentView.leftAnchor)
      setPositionConstraint(for: documentView.topAnchor, refAnchor: contentView.topAnchor)

      setDimensionConstraint(for: documentView.widthAnchor,
                             constant: BackgroundView.backgroundViewBound)
      setDimensionConstraint(for: documentView.heightAnchor,
                             constant: BackgroundView.backgroundViewBound)

      //--------------------------------------------------------------------------------


      documentView.addSubview(svgView)

      svgView.translatesAutoresizingMaskIntoConstraints = false
      
      // setPositionConstraint(for: svgView.leftAnchor, refAnchor: documentView.leftAnchor)
      // setPositionConstraint(for: svgView.topAnchor, refAnchor: documentView.topAnchor)

      setPositionConstraint(for: svgView.centerXAnchor, refAnchor: documentView.centerXAnchor)
      setPositionConstraint(for: svgView.centerYAnchor, refAnchor: documentView.centerYAnchor)

      setDimensionConstraint(for: svgView.widthAnchor, svgUnit: doc?.svgWidth,
                             refAnchor: contentView.widthAnchor)
      setDimensionConstraint(for: svgView.heightAnchor, svgUnit: doc?.svgHeight,
                             refAnchor: contentView.heightAnchor)
    }
  }

  private func setupScrollView() {
    if let scrollView = getScrollView() {

      scrollView.documentView = BackgroundView()

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
                                        refAnchor: NSLayoutAnchor<T>) {
    anchor.constraint(equalTo: refAnchor).isActive = true
  }

  private func setDimensionConstraint(for anchor: NSLayoutDimension, constant: CGFloat) {
    anchor.constraint(equalToConstant: constant).isActive = true
  }

  private func setDimensionConstraint(for anchor: NSLayoutDimension,
                                      svgUnit: SCDSvgUnit?, refAnchor: NSLayoutDimension) {
    guard let unit = svgUnit else { return }

    let value = CGFloat(unit.value)

    if unit.measurement == .percentage {
      anchor.constraint(equalTo: refAnchor, multiplier: value * 0.01).isActive = true
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

class BackgroundView: NSView {

  static let backgroundViewBound: CGFloat = 2000

  static func center() -> NSPoint {
    let halfBound = backgroundViewBound / 2

    return NSPoint(x: halfBound, y: halfBound)
  }

  override var isFlipped: Bool {true}
}
