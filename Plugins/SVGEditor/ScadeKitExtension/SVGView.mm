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

- (void)setFrameSize:(NSSize)newSize {
  [super setFrameSize:newSize];

  if (rootSvg) {
    if (isRendered) {
      // TODO: Display::instance()->frameChanged()
    } else {
      [SCDRuntime renderSvg:rootSvg x:0 y:0 size:newSize];
      isRendered = YES;
    }
  }
}

- (void)setSvg:(SCDSvgBox*)svg {
  rootSvg = svg;
  isRendered = NO;
}

@end
