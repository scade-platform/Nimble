import ScadeKit

class WidgetUI: WidgetVisitor {

  public func apply(_ widget: SCDWidgetsWidget) {
    if let nativeWidget = widget as? SCDWidgetsNativeWidget,
       let view = getLayerView(of: nativeWidget),
       let layer = view.layer {

      let size = nativeWidget.size
      view.frame =  NSRect(x: 0, y: 0, width: size.width, height: size.height)

      layer.borderWidth = 1
      layer.borderColor = NSColor.systemBlue.cgColor

      let textSuperLayer = CALayer()
      textSuperLayer.layoutManager = CAConstraintLayoutManager()
      textSuperLayer.frame = view.frame
      layer.addSublayer(textSuperLayer)

      let textLayer = CATextLayer()
      textLayer.string = nativeWidget.eClass()?.name
      textLayer.foregroundColor = NSColor.black.cgColor
      textLayer.alignmentMode = .center
      textLayer.frame = view.bounds
      textLayer.contentsScale = NSScreen.main!.backingScaleFactor
      textLayer.constraints = [
        CAConstraint(attribute: .midX,
                     relativeTo: "superlayer",
                     attribute: .midX),
        CAConstraint(attribute: .midY,
                     relativeTo: "superlayer",
                     attribute: .midY)
      ]
      
      textSuperLayer.addSublayer(textLayer)
    }
  }

  private func getLayerView(of widget: SCDWidgetsWidget) -> NSView? {
    (widget.drawing as? EObject).flatMap { SCDRuntime.extract(intoLayer: $0) }
  }
}
