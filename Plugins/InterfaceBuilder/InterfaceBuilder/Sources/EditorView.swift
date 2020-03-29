import SVGEditor
import ScadeKit
import NimbleCore

class EditorView: SVGEditorView {
  
  let window = SCDLatticeWindow()

  public var observers = ObserverSet<EditorViewObserver>()
  
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
  }
}

public protocol EditorViewObserver: class {
  func didSelectWidget(_ widget: SCDWidgetsWidget)
}

public extension EditorViewObserver {
  func didSelectWidget(_ widget: SCDWidgetsWidget) {}
}
