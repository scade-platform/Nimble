#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


typedef NS_ENUM(NSInteger, SCDPlatformContactPhoneLabelKey);


/*PROTECTED REGION ID(8d68fd2ba72997788c278f308efdf896) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDPlatformContactPhone : EObject


@property(nonatomic) NSString* _Nonnull number;

@property(nonatomic) SCDPlatformContactPhoneLabelKey key;

@property(nonatomic) NSString* _Nonnull customKey;


/*PROTECTED REGION ID(ef91863acc03553d2a2896b0b87be53c) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
