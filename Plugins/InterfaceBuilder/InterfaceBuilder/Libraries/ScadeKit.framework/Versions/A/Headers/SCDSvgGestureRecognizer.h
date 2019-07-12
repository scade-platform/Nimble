#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@protocol SCDSvgTouchReceiver;

@class SCDSvgTouchEvent;

typedef NS_ENUM(NSInteger, SCDSvgTouchHandlerState);


/*PROTECTED REGION ID(66a329ad4c06f852bac2f100ad455f55) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDSvgGestureRecognizer : EObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;

- (instancetype _Nonnull)initWithHandler:
    (nonnull void (^)(SCDSvgGestureRecognizer* _Nullable))_
    NS_DESIGNATED_INITIALIZER;

@property(nonatomic, readonly) id<SCDSvgTouchReceiver> _Nullable target;

@property(nonatomic, readonly) SCDSvgTouchHandlerState state;

@property(nonatomic, getter=isEnabled) BOOL enabled;


- (SCDSvgTouchHandlerState)match:(SCDSvgTouchEvent* _Nonnull)event;


- (void)invoke:(SCDSvgGestureRecognizer* _Nullable)arg;


/*PROTECTED REGION ID(d919cc65eeeaddcb166a464e66602a92) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
