import ScadeKit

protocol WidgetVisitor {
  func visit(_ widget: SCDWidgetsWidget)
}

class TouchListenerApplier: WidgetVisitor {

  func visit(_ widget: SCDWidgetsWidget) {
    addListener(widget)

    if let contaner = widget as? SCDWidgetsContainer {
      contaner.children.forEach { visit($0)}
    }
  }

  private func addListener(_ widget: SCDWidgetsWidget) {
    widget.drawing?.gestureRecognizers.append(
      SCDSvgTapGestureRecognizer(handler: {h in print(widget)}))
  }
}
