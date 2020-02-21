import ScadeKit
import SVGEditor

class WidgetSelector: SVGLayerSelector, WidgetVisitor {

  public override init() {}

  public func apply(_ widget: SCDWidgetsWidget) {
    if let drawable = widget.drawing {
      apply(drawable)
    }
  }
}
