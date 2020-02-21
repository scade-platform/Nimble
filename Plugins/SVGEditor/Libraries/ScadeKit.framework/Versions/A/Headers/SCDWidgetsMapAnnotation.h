#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@protocol SCDSvgDrawable;

@class SCDPlatformLocationCoordinate;


/*PROTECTED REGION ID(cc4daebee1ea64a4cddf20b24110b5cb) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDWidgetsMapAnnotation : EObject


@property(nonatomic) SCDPlatformLocationCoordinate* _Nonnull location;

@property(nonatomic) id<SCDSvgDrawable> _Nullable drawing;


/*PROTECTED REGION ID(bc5036a9acfe6a05bae3714a5ab51081) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
