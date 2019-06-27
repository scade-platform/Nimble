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
            containerObject->add(
                [PageHighlighter createBorder:containerObject->getFrame()]);
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

+ (DisplayObject_ptr)createBorder:(RectF)rect {
  auto res = DisplayFactory::createRect();
  res->set(0, 0, rect.size.width, rect.size.height);
  res->setFillColor(0, 0, 0, 0);
  res->setStrokeWidth(3);
  res->setStrokeColor(255, 0, 0);

  return res;
}


@end
