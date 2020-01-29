#import "ScadeKitExtensions.h"
#include <phoenix/display/display.hpp>

@implementation ScadeKitExtensions

+ (NSView*) createPhoenixView {
  using namespace phoenix::display;
  Display::reset();

  return Display::instance()->getDisplayView();
}

@end
