#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@class SCDGraphicsPoint;
@class SCDGraphicsDimension;
@class SCDLayoutLayoutData;


/*PROTECTED REGION ID(2b3f358d3c83bd9f844a479d78b8c17d) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@protocol SCDLayoutNode <EObject>


@property(nonatomic) SCDGraphicsPoint* _Nonnull location;

@property(nonatomic) SCDGraphicsDimension* _Nonnull size;

@property(nonatomic) SCDGraphicsDimension* _Nonnull contentSize;

@property(nonatomic) SCDLayoutLayoutData* _Nullable layoutData;


/*PROTECTED REGION ID(e301f7a00a9adc8eb44e5736df3be070) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
