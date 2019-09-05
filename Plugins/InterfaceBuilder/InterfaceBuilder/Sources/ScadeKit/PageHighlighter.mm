#import "PageHighlighter.h"
#import <support/runtime.h>
#import <widgets/WidgetProxy.hpp>

#include <phoenix/display/display.hpp>
#include <phoenix/display/DisplayFactory.hpp>
#include <phoenix/display/geometry.hpp>


using namespace phoenix::display;
using namespace phoenix::display::geometry;

@implementation PageHighlighter

- (void)select:(SCDWidgetsWidget*)widget {
  if (auto const& proxy = widget.proxy) {
    if (auto const& widgetProxy = proxy->as<SCDWidgetsWidgetProxy>()) {
      if (auto const& drawing = widgetProxy->getDrawing()) {
        if (auto const& displayObject = drawing->getDisplayObject()) {
          if (auto const& containerObject =
                  displayObject->as<ContainerObject>()) {

            auto const& size = containerObject->getFullTransformation()
                                   .inverse()
                                   .mapRect(containerObject->getFrame())
                                   .size;

            containerObject->add([PageHighlighter createBorder:size]);
          }
        }
      }
    }
  }
}

- (void)unselect:(SCDWidgetsWidget*)widget {
  if (auto const& proxy = widget.proxy) {
    if (auto const& widgetProxy = proxy->as<SCDWidgetsWidgetProxy>()) {
      if (auto const& drawing = widgetProxy->getDrawing()) {
        if (auto const& displayObject = drawing->getDisplayObject()) {
          if (auto const& containerObject =
                  displayObject->as<ContainerObject>()) {
            containerObject->remove(containerObject->back());
          }
        }
      }
    }
  }
}

+ (DisplayObject_ptr)createBorder:(SizeF)size {
  auto res = DisplayFactory::createRect();
  auto strokeWidth = 2;
  auto halfStrokeWidth = strokeWidth / 2;

  res->set(halfStrokeWidth, halfStrokeWidth, size.width - strokeWidth,
           size.height - strokeWidth);

  res->setFillColor(0, 0, 0, 0);
  res->setStrokeWidth(strokeWidth);
  res->setStrokeColor(73, 158, 255);

  return res;
}


@end
