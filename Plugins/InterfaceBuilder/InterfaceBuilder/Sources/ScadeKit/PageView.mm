#import "PageView.h"
#include <phoenix/display/display.hpp>

@implementation PageView

- (void)awakeFromNib {
  self.phoenixView = phoenix::display::Display::createView();
  [self.phoenixView.layer setBackgroundColor:[NSColor clearColor].CGColor];

  [self addSubview:self.phoenixView];
}


@end
