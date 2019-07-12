#import <Foundation/Foundation.h>

#import <ScadeKit/SCDSvgTransform.h>


@protocol SCDSvgTransform;

@class SCDGraphicsPointF;


/*PROTECTED REGION ID(778691fb0d9eae6bfca1d4404be40042) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDSvgRotate : EObject <SCDSvgTransform>


@property(nonatomic) float angle;

@property(nonatomic) SCDGraphicsPointF* _Nonnull point;


/*PROTECTED REGION ID(d19d20b459faefcb9fc15ae8d4586c24) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
