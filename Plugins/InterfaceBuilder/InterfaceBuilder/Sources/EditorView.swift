import SVGEditor
import ScadeKit
import NimbleCore

class EditorView: SVGEditorView {
  
  let window = SCDLatticeWindow()

  var observers = ObserverSet<EditorViewObserver>()

  var pageDocument: PageDocument? {
    return document as? PageDocument
  }

  override func setupSVGView() {
    setupElementSelector()
  }

  override func setupElementSelector() {
    if elementSelector == nil {
      let widgetSelector = WidgetSelector(svgView, editorView: self)

      guard let page = pageDocument?.page else { return }
      widgetSelector.visit(page)
      elementSelector = widgetSelector
    }
  }

  open override func didOpenDocument(_ document: Document) {
    super.didOpenDocument(document)

    pageDocument?.adapter.show(window)

    guard let page = pageDocument?.page else { return }

    WidgetUI().visit(page)
  }
}

protocol EditorViewObserver: class {
  func editorDidChangeSelection(editor: EditorView, widget: SCDWidgetsWidget)
}

extension EditorViewObserver {
  func editorDidChangeSelection(editor: EditorView, widget: SCDWidgetsWidget) {}
}
