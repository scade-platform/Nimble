#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@class SCDGraphicsPointF;

typedef NS_ENUM(NSInteger, SCDSvgTouchEventPhase);


/*PROTECTED REGION ID(855be18238324779fe95014b59a48201) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDSvgTouchEvent : EObject


@property(nonatomic) SCDSvgTouchEventPhase phase;

@property(nonatomic) SCDGraphicsPointF* _Nonnull location;

@property(nonatomic) SCDGraphicsPointF* _Nonnull startLocation;

@property(nonatomic) float deltaX;

@property(nonatomic) float deltaY;


/*PROTECTED REGION ID(50c0d565d39869259f85247a39e97e38) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
