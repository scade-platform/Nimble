import ScadeKit
import ScadeKitExtension
import SVGEditor

class WidgetSelector: SVGLayerSelector, WidgetVisitor {

  private weak var editorView: EditorView?

  private weak var selected: SCDWidgetsWidget?

  public init(_ svgView: SVGView, editorView: EditorView) {
    self.editorView = editorView
    super.init(svgView)
  }

  deinit {
    doSelect(nil)
  }

  public func apply(_ widget: SCDWidgetsWidget) {
    if let drawable = widget.drawing {
      drawable.gestureRecognizers.append(
        SCDSvgTapGestureRecognizer(
          handler: { [weak self, weak widget] h in
            if let widget = widget {
              self?.handleOnTap(with: h)
              self?.select(widget)
            }
          } ))
    }
  }

  private func select(_ widget: SCDWidgetsWidget) {
    if let oldSelected = selected {
      if !(oldSelected === widget) {
        //onUnselect(oldSelected)
        doSelect(widget)
      }
    } else {
      doSelect(widget)
    }
  }

  private func doSelect(_ widget: SCDWidgetsWidget?) {
    if let editorView = self.editorView {
      editorView.observers.notify {
        $0.editorDidChangeSelection(editor: editorView, widget: widget)
      }
    }

    selected = widget
  }
}
