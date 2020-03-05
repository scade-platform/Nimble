import Cocoa
import NimbleCore
import SVGEditor

class InterfaceBuilderView: SVGEditorView {

  override func setupElementSelector() {
    if elementSelector == nil {
      elementSelector = WidgetSelector()
    }

    if let pageDocument = doc as? PageDocument,
       let page = pageDocument.page,
       let selector = elementSelector as? WidgetSelector {

      selector.visit(page)
    }
  }
}

extension InterfaceBuilderView: WorkbenchEditor { }
