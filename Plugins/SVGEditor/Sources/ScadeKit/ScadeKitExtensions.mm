#import "ScadeKitExtensions.h"
#include <phoenix/display/display.hpp>

@implementation ScadeKitExtensions

+ (NSView*) createScadeKitView {
  using namespace phoenix::display;
  Display::reset();

  return Display::instance()->getDisplayView();
}

@end
