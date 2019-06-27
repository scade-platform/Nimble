import ScadeKit

class WidgetHighlighter: WidgetVisitor {
  private var selected: SCDWidgetsWidget?
  private let pageHighlighter = PageHighlighter()

  public func apply(_ widget: SCDWidgetsWidget) {
    widget.drawing?.gestureRecognizers.append(
      SCDSvgTapGestureRecognizer(handler: {[unowned self] h in self.select(widget)}))
  }

  private func select(_ widget: SCDWidgetsWidget) {
    if let oldSelected = selected {
      if oldSelected != widget {
        onUnselect(oldSelected)
        doSelect(widget)
      }
    } else {
      doSelect(widget)
    }
  }

  private func doSelect(_ widget: SCDWidgetsWidget) {
    onSelect(widget)
    selected = widget
  }

  private func onUnselect(_ widget: SCDWidgetsWidget) {
    pageHighlighter.unselect(widget)
    //print("unselect: \(widget)")
  }

  private func onSelect(_ widget: SCDWidgetsWidget) {
    pageHighlighter.select(widget)
    //print("select: \(widget)")
  }
  
}

