import SVGEditor
import ScadeKit

class EditorView: SVGEditorView {

  let pageApp = PageApp()

  open override func viewDidLoad() {
    super.viewDidLoad()

    setupScrollView()
    setupElementSelector()
  }

  override func onOpenDocument() {
    super.onOpenDocument()

    (doc as? PageDocument)?.pageApp.launch()
  }
}
