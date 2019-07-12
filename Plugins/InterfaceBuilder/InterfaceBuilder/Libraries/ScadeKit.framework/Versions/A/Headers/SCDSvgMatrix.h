#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


/*PROTECTED REGION ID(b80170c15f05182d7a44efca9c9839d6) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDSvgMatrix : EObject


@property(nonatomic) float translateX;

@property(nonatomic) float translateY;

@property(nonatomic) float scaleX;

@property(nonatomic) float scaleY;

@property(nonatomic) float skewX;

@property(nonatomic) float skewY;


- (BOOL)isOrthogonal;

- (SCDSvgMatrix* _Nonnull)multiply:(SCDSvgMatrix* _Nonnull)matrix;

- (SCDSvgMatrix* _Nonnull)inverse;


/*PROTECTED REGION ID(94f40438a0797d9794c1131e9b359144) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
