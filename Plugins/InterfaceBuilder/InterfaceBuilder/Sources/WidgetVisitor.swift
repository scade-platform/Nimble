import ScadeKit

protocol WidgetVisitor {
  func visit(_ widget: SCDWidgetsWidget)

  func apply(_ widget: SCDWidgetsWidget)
}

extension WidgetVisitor {

  func visit(_ widget: SCDWidgetsWidget) {
    apply(widget)

    if let contaner = widget as? SCDWidgetsContainer {
      contaner.children.forEach { visit($0)}
    }

    else if let list = widget as? SCDWidgetsList {
      if let element = list.template.element {
        visit(element)
      }
    }

    else if let slider = widget as? SCDWidgetsSlider {
      visit(slider.template)
    }
  }
}
