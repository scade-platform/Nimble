#import <Foundation/Foundation.h>

#import <ScadeKit/SCDSvgAnimation.h>


@class SCDSvgTimeFunction;
@class SCDSvgAnimation;

typedef NS_ENUM(NSInteger, SCDSvgFillMode);


/*PROTECTED REGION ID(6e50cb3829fbcf2c3d2ca7ac075dbc76) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDSvgBaseAnimation : SCDSvgAnimation


@property(nonatomic) SCDSvgFillMode fillMode;

@property(nonatomic, getter=isAdditive) BOOL additive;

@property(nonatomic, getter=isCumulative) BOOL cumulative;

@property(nonatomic) SCDSvgTimeFunction* _Nonnull timeFunction;


/*PROTECTED REGION ID(3d2ab62280038eec2250e78a36bfd793) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
