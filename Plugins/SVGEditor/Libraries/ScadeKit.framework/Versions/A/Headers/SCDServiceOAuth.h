#import <Foundation/Foundation.h>

#import <ScadeKit/SCDServiceAuth.h>


@protocol SCDServiceAuth;

@class SCDServiceOAuthFlow;
@class SCDServiceOAuthCredential;
@class SCDServiceOAuthToken;


/*PROTECTED REGION ID(432c31aaa8fccfd6448c97c1f1a89e80) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDServiceOAuth : EObject <SCDServiceAuth>


@property(nonatomic) SCDServiceOAuthFlow* _Nullable flow;

@property(nonatomic) SCDServiceOAuthCredential* _Nullable credential;

@property(nonatomic) SCDServiceOAuthToken* _Nullable token;


/*PROTECTED REGION ID(3acb52dc31de184633ea23153e1a413d) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
