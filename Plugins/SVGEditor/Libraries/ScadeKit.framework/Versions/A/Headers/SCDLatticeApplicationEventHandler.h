#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


/*PROTECTED REGION ID(79b3e745a920c535d22d71cb04ce42ab) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDLatticeApplicationEventHandler : EObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;

- (instancetype _Nonnull)initWithHandler:(nonnull void (^)(BOOL))_
    NS_DESIGNATED_INITIALIZER;


- (void)invoke:(BOOL)arg;


/*PROTECTED REGION ID(a4b8499851911a93da4e392bba226e93) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
