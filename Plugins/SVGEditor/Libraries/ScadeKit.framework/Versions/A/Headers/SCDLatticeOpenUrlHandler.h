#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


/*PROTECTED REGION ID(32223f9f09a47f2074466b7095ec4a8f) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDLatticeOpenUrlHandler : EObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;

- (instancetype _Nonnull)initWithHandler:(nonnull void (^)(NSString* _Nonnull))_
    NS_DESIGNATED_INITIALIZER;


- (void)invoke:(NSString* _Nonnull)arg;


/*PROTECTED REGION ID(3a68aa5f757f4f749c56988c9dcb3b39) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
