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

  override func viewDidLoad() {
    super.viewDidLoad()

    setupDocument()
    let svgView = setupSVGView(for: view)
    scrollView.documentView = svgView
    setupScrollView()

    elementSelector = createElementSelector()
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
    
    //scrollView.allowsMagnification = true
    //scrollView.magnification = 10
  }
}

extension SVGEditorView: WorkbenchEditor { }

extension SVGEditorView: DocumentObserver {

  func documentFileDidChange(_ document: Document) {
    //loadPage()
  }
}

