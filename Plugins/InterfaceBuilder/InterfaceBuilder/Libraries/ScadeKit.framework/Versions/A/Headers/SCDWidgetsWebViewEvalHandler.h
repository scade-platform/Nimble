#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


/*PROTECTED REGION ID(626039066d217bdd13afc9e12495349c) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDWidgetsWebViewEvalHandler : EObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;

- (instancetype _Nonnull)initWithHandler:(nonnull void (^)(NSString* _Nonnull))_
    NS_DESIGNATED_INITIALIZER;


- (void)invoke:(NSString* _Nonnull)arg;


/*PROTECTED REGION ID(86c5d0ce1bb8d0b55431e277a6b588f7) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
