#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


/*PROTECTED REGION ID(14d5fc85404894eb0a2ad0a4b47d6df5) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDPlatformCameraErrorHandler : EObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;

- (instancetype _Nonnull)initWithHandler:(nonnull void (^)(NSString* _Nonnull))_
    NS_DESIGNATED_INITIALIZER;


- (void)invoke:(NSString* _Nonnull)arg;


/*PROTECTED REGION ID(671ad39cf2439cde1f42171f1edeb852) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
