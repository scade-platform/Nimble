#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@class SCDPlatformCameraOptions;
@class SCDPlatformCameraSuccessHandler;
@class SCDPlatformCameraErrorHandler;


/*PROTECTED REGION ID(c8d436dcc1dc9f9503a927816c373454) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDPlatformCamera : EObject


- (void)getPicture:(SCDPlatformCameraOptions* _Nonnull)options
         onSuccess:(SCDPlatformCameraSuccessHandler* _Nullable)onSuccess
           onError:(SCDPlatformCameraErrorHandler* _Nullable)onError;


/*PROTECTED REGION ID(4232c0e703ed12e93bbeb6192e81091f) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
