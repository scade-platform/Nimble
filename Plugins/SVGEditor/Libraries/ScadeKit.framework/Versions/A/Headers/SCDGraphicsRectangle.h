#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@class SCDGraphicsPoint;
@class SCDGraphicsDimension;


/*PROTECTED REGION ID(07fd4270d2e2de8ff59ad3f3404e58a3) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDGraphicsRectangle : EObject


@property(nonatomic) SCDGraphicsPoint* _Nonnull location;

@property(nonatomic) SCDGraphicsDimension* _Nonnull bounds;


- (SCDGraphicsRectangle* _Nonnull)join:
    (SCDGraphicsRectangle* _Nonnull)rectangle;

- (SCDGraphicsRectangle* _Nonnull)unite:
    (SCDGraphicsRectangle* _Nonnull)rectangle;


/*PROTECTED REGION ID(661a71c492d4257fee5fdeee8502d79f) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
