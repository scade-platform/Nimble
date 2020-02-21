#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@class SCDWidgetsTextChangeEvent;


/*PROTECTED REGION ID(ce0e0a2759abd53264d6a47e49b776a6) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDWidgetsTextChangeEventHandler : EObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;

- (instancetype _Nonnull)initWithHandler:
    (nonnull void (^)(SCDWidgetsTextChangeEvent* _Nullable))_
    NS_DESIGNATED_INITIALIZER;


- (void)invoke:(SCDWidgetsTextChangeEvent* _Nullable)arg;


/*PROTECTED REGION ID(bc8a1d2d8889565022ef6a5eae509ba6) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
