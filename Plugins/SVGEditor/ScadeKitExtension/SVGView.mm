#import "SVGView.h"
#include <phoenix/display/display.hpp>

@implementation SVGView : NSView

- (id)init {
  self = [super init];
  if (self) {
    using namespace phoenix::display;
    Display::instance()->setDisplayView((__bridge void*)self);
    [self.layer setBackgroundColor:[NSColor clearColor].CGColor];
    isRendered = NO;
  }
  return self;
}

- (void)setFrameSize:(NSSize)newSize {
  [super setFrameSize:newSize];

  if (rootSvg) {
    if (isRendered) {
      // TODO: Display::instance()->frameChanged()
    } else {
      [self render: newSize];
    }
  }
}

- (void)setSvg:(SCDSvgBox*)svg {
  rootSvg = svg;

  if (isRendered) {
      [self render: self.frame.size];
  }
}

- (BOOL)isFlipped {
  return YES;
}

- (void)render:(NSSize)size {
    [SCDRuntime renderSvg:rootSvg x:0 y:0 size:size];
    isRendered = YES;
}

@end
