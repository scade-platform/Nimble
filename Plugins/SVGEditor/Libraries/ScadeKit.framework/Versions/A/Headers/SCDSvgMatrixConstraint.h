#import <Foundation/Foundation.h>

#import <ScadeKit/SCDSvgConstraint.h>


@class SCDExprExpression;
@class SCDSvgConstraint;


/*PROTECTED REGION ID(4cbf522eb6c515078ff3421e1121a31b) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDSvgMatrixConstraint : SCDSvgConstraint


@property(nonatomic) SCDExprExpression* _Nullable scaleX;

@property(nonatomic) SCDExprExpression* _Nullable skewX;

@property(nonatomic) SCDExprExpression* _Nullable translateX;

@property(nonatomic) SCDExprExpression* _Nullable skewY;

@property(nonatomic) SCDExprExpression* _Nullable scaleY;

@property(nonatomic) SCDExprExpression* _Nullable translateY;


/*PROTECTED REGION ID(f720adfbd104e980e46824380a8f3a5f) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
