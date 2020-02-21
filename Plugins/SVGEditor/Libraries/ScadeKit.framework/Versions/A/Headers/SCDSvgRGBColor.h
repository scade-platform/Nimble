#import <Foundation/Foundation.h>

#import <ScadeKit/SCDSvgColor.h>


@class SCDSvgColor;


/*PROTECTED REGION ID(12d936b4cc3051eaa2957d50d8defa98) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDSvgRGBColor : SCDSvgColor


@property(nonatomic) float r;

@property(nonatomic) float g;

@property(nonatomic) float b;

@property(nonatomic) float a;


- (void)setCss:(NSString* _Nonnull)value;


/*PROTECTED REGION ID(7fe5bb32149fd2b99dfcd9b9997953e7) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
