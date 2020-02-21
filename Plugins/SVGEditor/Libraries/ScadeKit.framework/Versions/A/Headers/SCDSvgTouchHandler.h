#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@class SCDSvgTouchEvent;

typedef NS_ENUM(NSInteger, SCDSvgTouchHandlerState);


/*PROTECTED REGION ID(e7e95efa1881aea2ac97f1b58a329e10) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDSvgTouchHandler : EObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;

- (instancetype _Nonnull)initWithHandler:
    (nonnull SCDSvgTouchHandlerState (^)(SCDSvgTouchEvent* _Nonnull))_
    NS_DESIGNATED_INITIALIZER;


- (SCDSvgTouchHandlerState)invoke:(SCDSvgTouchEvent* _Nonnull)arg;


/*PROTECTED REGION ID(501c35c8767732b84c59014ab481eb48) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
