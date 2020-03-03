import Cocoa
import NimbleCore
import SVGEditor
import ScadeKitExtension

class InterfaceBuilderView: NSViewController, SVGViewProtocol {

  var svgView: SVGView? = nil

  let elementSelector: SVGElementSelector = WidgetSelector()

  weak var doc: SVGDocumentProtocol? = nil

  override func viewDidLoad() {
    super.viewDidLoad()

    setupDocument()

    svgView = createSVGView(for: view)
    setupSVGView()
  }

  func setupElementSelector() {
    if let pageDocument = doc as? PageDocument,
       let page = pageDocument.page,
       let selector = elementSelector as? WidgetSelector {

      selector.visit(page)
    }
  }
}

extension InterfaceBuilderView: WorkbenchEditor { }

extension InterfaceBuilderView: DocumentObserver {

  func documentFileDidChange(_ document: Document) {
    //loadPage()
  }
}
