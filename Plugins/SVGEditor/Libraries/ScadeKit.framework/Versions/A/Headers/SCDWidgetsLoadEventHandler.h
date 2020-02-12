#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@class SCDWidgetsLoadEvent;


/*PROTECTED REGION ID(ace5e94a31432621b000db15491f131b) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDWidgetsLoadEventHandler : EObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;

- (instancetype _Nonnull)initWithHandler:
    (nonnull void (^)(SCDWidgetsLoadEvent* _Nullable))_
    NS_DESIGNATED_INITIALIZER;


- (void)invoke:(SCDWidgetsLoadEvent* _Nullable)arg;


/*PROTECTED REGION ID(d73a9e3c13453e85215ba013c88172ff) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
