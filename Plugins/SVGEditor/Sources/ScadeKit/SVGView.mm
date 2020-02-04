#import "SVGView.h"
#include <phoenix/display/display.hpp>

@implementation SVGView : NSView

- (id)init {
  self = [super init];
  if (self) {
    using namespace phoenix::display;
    Display::instance()->setDisplayView((__bridge void*)self);
    [self.layer setBackgroundColor:[NSColor clearColor].CGColor];
  }
  return self;
}

- (void)render:(SCDSvgBox*)svg {
  [SCDRuntime renderSvg:svg x:0 y:0 size:self.frame.size];
}

@end
