import SVGEditor
import ScadeKit
import NimbleCore

class EditorView: SVGEditorView {
  
  let window = SCDLatticeWindow()

  var isDocumentOpened = false

  var observers = ObserverSet<EditorViewObserver>()

  var pageDocument: PageDocument? {
    return document as? PageDocument
  }

  override func setupSVGView() {
    setupElementSelector()

    if isDocumentOpened {
      showPage(on: window)
    }
  }

  override func setupElementSelector() {
    let widgetSelector = WidgetSelector(svgView, editorView: self)

    guard let page = pageDocument?.page else { return }
    widgetSelector.visit(page)

    elementSelector = widgetSelector
  }

  override func didOpenDocument() {
    super.didOpenDocument()

    showPage(on: window)
    isDocumentOpened = true
  }

  private func showPage(on window: SCDLatticeWindow) {
    pageDocument?.self.adapter.show(window)
  }
}

protocol EditorViewObserver: class {
  func editorDidChangeSelection(editor: EditorView, widget: SCDWidgetsWidget?)
}

extension EditorViewObserver {
  func editorDidChangeSelection(editor: EditorView, widget: SCDWidgetsWidget?) {}
}
