import Cocoa
import NimbleCore
import SVGEditor

class EditorView: SVGEditorView {

  @IBOutlet weak var scrollView: NSScrollView!

  public override func getScrollView() -> NSScrollView? {
    return scrollView
  }

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

// extension EditorView: WorkbenchEditor {
//   public var editorMenu: NSMenu? {
//     SVGEditorMenu.shared.editor = self

//     return SVGEditorMenu.editorMenu
//   }
// }
