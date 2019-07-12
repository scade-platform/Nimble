#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@class SCDWidgetsEvent;


/*PROTECTED REGION ID(e7bc6386f3669654f8994db9fc84a4b8) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDWidgetsEventHandler : EObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;

- (instancetype _Nonnull)initWithHandler:
    (nonnull void (^)(SCDWidgetsEvent* _Nullable))_ NS_DESIGNATED_INITIALIZER;


- (void)invoke:(SCDWidgetsEvent* _Nullable)arg;


/*PROTECTED REGION ID(f7669062b8d46d5d2d5349b76e172c67) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
