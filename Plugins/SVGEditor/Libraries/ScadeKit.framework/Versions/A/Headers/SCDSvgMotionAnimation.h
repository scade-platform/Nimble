#import <Foundation/Foundation.h>

#import <ScadeKit/SCDSvgBaseAnimation.h>


@protocol SCDSvgValueFunction;

@class SCDSvgPath;
@class SCDSvgBaseAnimation;


/*PROTECTED REGION ID(f895bf77d028c029f8d51456ba35e01f) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDSvgMotionAnimation : SCDSvgBaseAnimation


@property(nonatomic) SCDSvgPath* _Nullable path;

@property(nonatomic) id<SCDSvgValueFunction> _Nullable pointFunction;


/*PROTECTED REGION ID(e907ca6cf0d6585eca81a8ed37a3c9bc) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
