#import "PageView.h"
#include <phoenix/display/display.hpp>

@implementation PageView

- (void)awakeFromNib {
  using namespace phoenix::display;
  Display::reset();
  self.phoenixView = Display::instance()->getDisplayView();
  [self.phoenixView.layer setBackgroundColor:[NSColor clearColor].CGColor];

  [self addSubview:self.phoenixView];
}


@end
