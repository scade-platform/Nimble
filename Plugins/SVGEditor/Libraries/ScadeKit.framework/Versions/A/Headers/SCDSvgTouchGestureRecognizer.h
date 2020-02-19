#import <Foundation/Foundation.h>

#import <ScadeKit/SCDSvgGestureRecognizer.h>


@class SCDSvgTouchHandler;
@class SCDSvgTouchEvent;
@class SCDSvgGestureRecognizer;

typedef NS_ENUM(NSInteger, SCDSvgTouchHandlerState);


/*PROTECTED REGION ID(92cc377631973e3e7f4787481d6a45e7) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDSvgTouchGestureRecognizer : SCDSvgGestureRecognizer


@property(nonatomic) SCDSvgTouchHandler* _Nullable handler;

@property(nonatomic, readonly) SCDSvgTouchEvent* _Nonnull lastTouch;


/*PROTECTED REGION ID(1aacdb1a83bfe7e5269962eee850b2e0) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
