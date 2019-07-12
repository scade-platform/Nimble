#import <Foundation/Foundation.h>

#import <ScadeKit/SCDSvgBaseAnimation.h>


@class SCDSvgBaseAnimation;


/*PROTECTED REGION ID(82b1fa958261bb0297aaae5924e4c53b) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDSvgRotateAnimation : SCDSvgBaseAnimation


@property(nonatomic) float angle;

@property(nonatomic) float anchorX;

@property(nonatomic) float anchorY;

@property(nonatomic, getter=isAbsolute) BOOL absolute;


/*PROTECTED REGION ID(30e3e309a4e21c00d6b76b25c2d5890a) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
