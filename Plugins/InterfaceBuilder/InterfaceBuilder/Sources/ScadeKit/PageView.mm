#import "PageView.h"
#include <phoenix/display/display.hpp>

@implementation PageView

- (void)awakeFromNib {
  self.phoenixView = phoenix::display::Display::instance()->getDisplayView();
  [self.phoenixView.layer setBackgroundColor:[NSColor clearColor].CGColor];

  [self addSubview:self.phoenixView];
}


@end
