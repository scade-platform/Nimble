#import <Foundation/Foundation.h>

#import <ScadeKit/SCDSvgTransform.h>


@protocol SCDSvgTransform;


/*PROTECTED REGION ID(6911f953aa4b1ca6029a5a801273be85) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDSvgMatrixTransform : EObject <SCDSvgTransform>


@property(nonatomic) float translateX;

@property(nonatomic) float translateY;

@property(nonatomic) float scaleX;

@property(nonatomic) float scaleY;

@property(nonatomic) float skewX;

@property(nonatomic) float skewY;


/*PROTECTED REGION ID(3841472640b00169c0608a4ad22bed8a) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
