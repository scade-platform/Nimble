#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@class SCDNetworkResponse;


/*PROTECTED REGION ID(71841006d6df01360cea57e3280641ed) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDNetworkAsyncCallback : EObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;

- (instancetype _Nonnull)initWithHandler:
    (nonnull void (^)(SCDNetworkResponse* _Nullable))_
    NS_DESIGNATED_INITIALIZER;


- (void)invoke:(SCDNetworkResponse* _Nullable)arg;


/*PROTECTED REGION ID(bcfef23779c962253fed0f84eec5b426) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
