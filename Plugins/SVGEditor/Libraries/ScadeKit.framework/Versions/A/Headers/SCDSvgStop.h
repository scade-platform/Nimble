#import <Foundation/Foundation.h>

#import <ScadeKit/SCDSvgElement.h>


@protocol SCDSvgElement;

@class SCDSvgColor;


/*PROTECTED REGION ID(e38ad7cc6330f8ef762bc9e65adad8b3) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDSvgStop : EObject <SCDSvgElement>

- (instancetype _Nonnull)init NS_UNAVAILABLE;

- (instancetype _Nonnull)initWithColor:(SCDSvgColor* _Nonnull)color
    NS_DESIGNATED_INITIALIZER;

@property(nonatomic) float offset;

@property(nonatomic) float opacity;

@property(nonatomic) SCDSvgColor* _Nonnull color;


/*PROTECTED REGION ID(e5d0e0a27d76fd884212a3fd0af7132d) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
