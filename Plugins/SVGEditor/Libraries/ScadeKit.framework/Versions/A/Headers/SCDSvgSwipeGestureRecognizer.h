#import <Foundation/Foundation.h>

#import <ScadeKit/SCDSvgGestureRecognizer.h>


@class SCDSvgGestureRecognizer;
@class SCDSvgTouchEvent;

typedef NS_ENUM(NSInteger, SCDSvgSwipeDirection);
typedef NS_ENUM(NSInteger, SCDSvgTouchHandlerState);


/*PROTECTED REGION ID(f605721a2af6bc93c07a3246c3344d9c) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDSvgSwipeGestureRecognizer : SCDSvgGestureRecognizer


@property(nonatomic) SCDSvgSwipeDirection direction;


/*PROTECTED REGION ID(6b32b39b5fabc1ab91cd94a04e744164) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
