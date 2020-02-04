#import <Cocoa/Cocoa.h>
#import <ScadeKit/ScadeKit.h>

@interface SVGView: NSView

-(void) render:(SCDSvgBox*)svg;

@end


