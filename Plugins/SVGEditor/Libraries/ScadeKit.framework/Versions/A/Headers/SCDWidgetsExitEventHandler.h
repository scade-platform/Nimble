#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@class SCDWidgetsExitEvent;


/*PROTECTED REGION ID(da3444f417c6378bbe49ec3295d5680f) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDWidgetsExitEventHandler : EObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;

- (instancetype _Nonnull)initWithHandler:
    (nonnull void (^)(SCDWidgetsExitEvent* _Nullable))_
    NS_DESIGNATED_INITIALIZER;


- (void)invoke:(SCDWidgetsExitEvent* _Nullable)arg;


/*PROTECTED REGION ID(3c80351bc6b1862e15bc4cd97d62c07e) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
