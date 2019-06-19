#import "PageView.h"
#include <phoenix/display/display.hpp>

@implementation PageView

- (void)awakeFromNib {
  self.phoenixView = phoenix::display::Display::createView();

  [self addSubview:self.phoenixView];
}


@end
