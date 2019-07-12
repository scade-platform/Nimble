#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@class SCDWidgetsLoadEvent;


/*PROTECTED REGION ID(3f03264f0397b5b4da42872927d894ec) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDWidgetsShouldLoadEventHandler : EObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;

- (instancetype _Nonnull)initWithHandler:
    (nonnull BOOL (^)(SCDWidgetsLoadEvent* _Nullable))_
    NS_DESIGNATED_INITIALIZER;


- (BOOL)invoke:(SCDWidgetsLoadEvent* _Nullable)arg;


/*PROTECTED REGION ID(27db0fc0ef9fa8cd065753128bb84b1b) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
