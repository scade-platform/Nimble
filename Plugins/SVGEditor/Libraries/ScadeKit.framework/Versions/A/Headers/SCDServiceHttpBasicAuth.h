#import <Foundation/Foundation.h>

#import <ScadeKit/SCDServiceAuth.h>


@protocol SCDServiceAuth;

@class SCDServiceHttpCredential;


/*PROTECTED REGION ID(514ed01eaa89edc4b2a2c1a866be6e3d) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDServiceHttpBasicAuth : EObject <SCDServiceAuth>


@property(nonatomic) SCDServiceHttpCredential* _Nullable credential;


/*PROTECTED REGION ID(f71050d5612f8dd312b7c7126bf46b9a) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
