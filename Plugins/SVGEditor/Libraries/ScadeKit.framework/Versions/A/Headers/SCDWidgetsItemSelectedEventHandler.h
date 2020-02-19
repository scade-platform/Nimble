#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@class SCDWidgetsItemSelectedEvent;


/*PROTECTED REGION ID(63beb6426e62c43ded804591a52cecab) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDWidgetsItemSelectedEventHandler : EObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;

- (instancetype _Nonnull)initWithHandler:
    (nonnull void (^)(SCDWidgetsItemSelectedEvent* _Nullable))_
    NS_DESIGNATED_INITIALIZER;


- (void)invoke:(SCDWidgetsItemSelectedEvent* _Nullable)arg;


/*PROTECTED REGION ID(90152320bfa22e533c01ccf6fccb083a) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
