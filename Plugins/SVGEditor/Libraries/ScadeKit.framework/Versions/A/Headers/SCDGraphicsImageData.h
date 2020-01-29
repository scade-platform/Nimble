#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


typedef NS_ENUM(NSInteger, SCDGraphicsImageFormat);


/*PROTECTED REGION ID(b71201be64a04603e20bff1e4538ccd6) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDGraphicsImageData : EObject


@property(nonatomic) NSData* _Nonnull data;

@property(nonatomic) long width;

@property(nonatomic) long height;

@property(nonatomic) SCDGraphicsImageFormat format;

@property(nonatomic, readonly) NSData* _Nonnull rgba32;


/*PROTECTED REGION ID(2008caa24a54cb34f017585329b6d456) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
