#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@class SCDWidgetsLoadFailedEvent;


/*PROTECTED REGION ID(54e04ca93b3a0e0420d5e0f2fefee015) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDWidgetsLoadFailedEventHandler : EObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;

- (instancetype _Nonnull)initWithHandler:
    (nonnull void (^)(SCDWidgetsLoadFailedEvent* _Nullable))_
    NS_DESIGNATED_INITIALIZER;


- (void)invoke:(SCDWidgetsLoadFailedEvent* _Nullable)arg;


/*PROTECTED REGION ID(ba8060bee380405f38c101f76ff3db9e) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
