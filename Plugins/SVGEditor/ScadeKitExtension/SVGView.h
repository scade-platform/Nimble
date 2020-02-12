#import <Cocoa/Cocoa.h>
#import <ScadeKit/ScadeKit.h>

@interface SVGView: NSView {
  SCDSvgBox* __weak rootSvg;
  BOOL isRendered;
}

- (void)setSvg:(SCDSvgBox*)svg;

@end


