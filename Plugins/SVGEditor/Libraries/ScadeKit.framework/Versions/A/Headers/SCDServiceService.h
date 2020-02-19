#import <Foundation/Foundation.h>

#import <ScadeKit/EClass.h>


@protocol SCDServiceAuth;

@class SCDServiceInvocation;
@class EObject;
@class EClass;


/*PROTECTED REGION ID(b72ce0b40acba247099e86639ab6a967) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDServiceService : EClass


@property(nonatomic) id<SCDServiceAuth> _Nullable auth;

@property(nonatomic) NSArray<SCDServiceInvocation*>* _Nonnull invocations;

@property(nonatomic) NSArray<EObject*>* _Nonnull contents;


/*PROTECTED REGION ID(6a45d6d0f193ec769619f5fc79fd92fa) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
