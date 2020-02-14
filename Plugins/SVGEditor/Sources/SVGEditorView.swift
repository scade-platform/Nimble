import Cocoa
import NimbleCore
import SVGEditor

class SVGEditorView: NSViewController, SVGViewProtocol {
  
  private var elementSelector: SVGElementSelector? = nil

  weak var doc: SVGDocumentProtocol? = nil

  @IBOutlet weak var scrollView: NSScrollView!

  func createElementSelector() -> SVGElementSelector {
    let selector = SVGLayerSelector()

    if let rootSvg = doc?.rootSvg {
      selector.visit(rootSvg)
    }

    return selector
  }

  override public func viewDidLoad() {
    super.viewDidLoad()

    setupDocument()
    let svgView = setupSVGView(for: view)
    scrollView.documentView = svgView
    setupScrollView()

    elementSelector = createElementSelector()
  }

  public func zoomIn() {
    scrollView.magnification += 0.25
  }

  public func zoomOut() {
    scrollView.magnification -= 0.25
  }

  public func actualSize() {
    scrollView.magnification = 1
  }

  private func setupScrollView() {    
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

extension SVGEditorView: WorkbenchEditor {
  public var editorMenu: NSMenu? {
    SVGEditorMenu.shared.editor = self

    return SVGEditorMenu.editorMenu
  }
}

extension SVGEditorView: DocumentObserver {

  public func documentFileDidChange(_ document: Document) {
    //loadPage()
  }
}

