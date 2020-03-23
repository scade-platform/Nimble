import Cocoa
import NimbleCore
import ScadeKitExtension

open class SVGEditorView: NSViewController, SVGEditorViewProtocol {

  @IBOutlet public weak var scrollView: NSScrollView!
  
  public var svgView = SVGView()

  public var elementSelector: SVGElementSelector! = nil

  public weak var document: SVGDocumentProtocol? = nil

  private var canvasView: CanvasView? {
    return scrollView.documentView as? CanvasView
  }

  open override func viewDidLoad() {
    super.viewDidLoad()

    setupDocument()
    setupScrollView()
    setupSVGView()
  }
  
  open func setupSVGView() {
    if let rootSvg = document?.rootSvg {
      svgView.setSvg(rootSvg)
    }
    setupElementSelector()
  }

  open func setupElementSelector() {
    if elementSelector == nil {
      elementSelector = SVGLayerSelector(svgView)
    }

    if let rootSvg = document?.rootSvg {
      elementSelector.process(rootSvg)
    }
  }

  public func setupScrollView() {
    let canvasView = CanvasView()
    canvasView.addSubview(svgView)

    scrollView.documentView = canvasView

    scrollView.hasHorizontalRuler = true
    scrollView.hasVerticalRuler = true
    scrollView.rulersVisible = true
    
    scrollView.verticalScrollElasticity = .none
    scrollView.horizontalScrollElasticity = .none
    
    scrollView.borderType = .lineBorder
    
    scrollView.horizontalRulerView?.measurementUnits = .points
    scrollView.verticalRulerView?.measurementUnits = .points
    
    scrollView.allowsMagnification = true
  }
  
  open func didOpenDocument(_ document: Document) {
    canvasView?.didOpenDocument(self.document,
                                scrollView: scrollView, svgView: svgView)
  }

  public func toggleGrid() {
    guard let canvasView = self.canvasView else { return }

    canvasView.isShowGrid.toggle()
    canvasView.setNeedsDisplay(canvasView.bounds)
  }

}

extension SVGEditorView: DocumentObserver {

  func setupDocument() {
    document?.observers.add(observer: self)
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
