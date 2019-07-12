#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@class SCDWidgetsEnterEvent;


/*PROTECTED REGION ID(d1ed57d1170e6020d7f50944437e19a0) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDWidgetsEnterEventHandler : EObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;

- (instancetype _Nonnull)initWithHandler:
    (nonnull void (^)(SCDWidgetsEnterEvent* _Nullable))_
    NS_DESIGNATED_INITIALIZER;


- (void)invoke:(SCDWidgetsEnterEvent* _Nullable)arg;


/*PROTECTED REGION ID(dd3c11b0ef63bc0b2da0a61c8c7b6a42) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
