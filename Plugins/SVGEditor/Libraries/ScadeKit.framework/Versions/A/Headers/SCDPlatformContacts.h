#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@class SCDPlatformContact;
@class SCDPlatformContactSearchResult;


/*PROTECTED REGION ID(cd905e261a5c7ae2b29ee8480a775af9) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDPlatformContacts : EObject


- (SCDPlatformContact* _Nullable)createContact;

- (SCDPlatformContactSearchResult* _Nullable)findAll;

- (SCDPlatformContactSearchResult* _Nullable)findByName:
    (NSString* _Nonnull)name;


/*PROTECTED REGION ID(48dfd96573b36dc1613b77748b60eb4d) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
