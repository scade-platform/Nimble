import SVGEditor
import ScadeKit
import NimbleCore

class EditorView: SVGEditorView {
  
  let window = SCDLatticeWindow()
  
  var pageDocument: PageDocument? {
    return document as? PageDocument
  }

  open override func viewDidLoad() {
    super.viewDidLoad()

    setupScrollView()
    setupElementSelector()
  }

   open override func didOpenDocument(_ document: Document) {
    super.didOpenDocument(document)

    pageDocument?.adapter.show(window)
  }
}
