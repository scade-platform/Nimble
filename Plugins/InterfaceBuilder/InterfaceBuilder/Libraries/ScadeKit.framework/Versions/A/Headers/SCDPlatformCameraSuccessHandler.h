#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


/*PROTECTED REGION ID(05c8dcf35b0a60ccffd73b9ef945a532) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDPlatformCameraSuccessHandler : EObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;

- (instancetype _Nonnull)initWithHandler:(nonnull void (^)(NSString* _Nonnull))_
    NS_DESIGNATED_INITIALIZER;


- (void)invoke:(NSString* _Nonnull)arg;


/*PROTECTED REGION ID(6f1da2396f13fae36dca4e44efec6b86) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
