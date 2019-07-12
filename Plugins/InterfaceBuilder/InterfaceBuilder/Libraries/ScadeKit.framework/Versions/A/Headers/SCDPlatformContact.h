#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@class SCDPlatformContactPhone;
@class SCDPlatformContactEmail;
@class SCDPlatformContactIM;
@class SCDPlatformContactUrl;
@class SCDPlatformContactAddress;


/*PROTECTED REGION ID(1bc9b6161975ef61fb3357d8778c83b8) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDPlatformContact : EObject


@property(nonatomic) NSString* _Nonnull id;

@property(nonatomic) NSString* _Nonnull note;

@property(nonatomic) NSArray<SCDPlatformContactPhone*>* _Nonnull phoneNumbers;

@property(nonatomic) NSArray<SCDPlatformContactEmail*>* _Nonnull emails;

@property(nonatomic) NSArray<SCDPlatformContactIM*>* _Nonnull ims;

@property(nonatomic) NSArray<SCDPlatformContactUrl*>* _Nonnull urls;

@property(nonatomic) NSArray<SCDPlatformContactAddress*>* _Nonnull addresses;

@property(nonatomic) NSString* _Nonnull familyName;

@property(nonatomic) NSString* _Nonnull givenName;

@property(nonatomic) NSString* _Nonnull middleName;

@property(nonatomic) NSString* _Nonnull prefix;

@property(nonatomic) NSString* _Nonnull sufix;

@property(nonatomic) NSString* _Nonnull organizationName;

@property(nonatomic) NSString* _Nonnull departmentName;

@property(nonatomic) NSString* _Nonnull jobTitle;


- (void)save;

- (void)remove;


/*PROTECTED REGION ID(d10174158b7be214ff88ba87ed32cd2d) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
