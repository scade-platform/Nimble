import Cocoa
import NimbleCore
import SVGEditor

class InterfaceBuilderView: NSViewController, SVGViewProtocol {

  private var elementSelector: SVGElementSelector? = nil

  weak var doc: SVGDocumentProtocol? = nil

  func createElementSelector() -> SVGElementSelector {
    let selector = WidgetSelector()

    if let pageDocument = doc as? PageDocument,
       let page = pageDocument.page {
      selector.visit(page)
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

extension InterfaceBuilderView: WorkbenchEditor { }

extension InterfaceBuilderView: DocumentObserver {

  func documentFileDidChange(_ document: Document) {
    //loadPage()
  }
}
