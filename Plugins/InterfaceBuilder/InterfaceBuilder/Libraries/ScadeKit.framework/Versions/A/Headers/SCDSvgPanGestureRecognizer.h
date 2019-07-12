#import <Foundation/Foundation.h>

#import <ScadeKit/SCDSvgGestureRecognizer.h>


@class SCDGraphicsPointF;
@class SCDSvgGestureRecognizer;
@class SCDSvgTouchEvent;

typedef NS_ENUM(NSInteger, SCDSvgTouchHandlerState);


/*PROTECTED REGION ID(c39192f72d4dc5a3e95c2ba1e161068d) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDSvgPanGestureRecognizer : SCDSvgGestureRecognizer


@property(nonatomic, readonly) SCDGraphicsPointF* _Nonnull location;

@property(nonatomic, readonly) SCDGraphicsPointF* _Nonnull startLocation;

@property(nonatomic, readonly) float deltaX;

@property(nonatomic, readonly) float deltaY;


/*PROTECTED REGION ID(55235ae16a779bdb4bae8bf8fab453b2) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
