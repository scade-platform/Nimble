#import <Foundation/Foundation.h>

#import <ScadeKit/SCDPlatformContactLabel.h>


@class SCDPlatformContactLabel;


/*PROTECTED REGION ID(a49b9164b1fc12e18445c460ba74307f) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDPlatformContactAddress : SCDPlatformContactLabel


@property(nonatomic) NSString* _Nonnull street;

@property(nonatomic) NSString* _Nonnull city;

@property(nonatomic) NSString* _Nonnull region;

@property(nonatomic) NSString* _Nonnull postalCode;

@property(nonatomic) NSString* _Nonnull country;


/*PROTECTED REGION ID(3ef68b7fcec0ed50a68c72e28fedbc49) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
