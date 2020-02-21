import Cocoa
import NimbleCore
import SVGEditor

class SVGEditorView: NSViewController, SVGViewProtocol {
  
  private var elementSelector: SVGElementSelector? = nil

  weak var doc: SVGDocumentProtocol? = nil

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
    setupSVGView(for: view)

    elementSelector = createElementSelector()
  }
}

extension SVGEditorView: WorkbenchEditor { }

extension SVGEditorView: DocumentObserver {

  func documentFileDidChange(_ document: Document) {
    //loadPage()
  }
}
