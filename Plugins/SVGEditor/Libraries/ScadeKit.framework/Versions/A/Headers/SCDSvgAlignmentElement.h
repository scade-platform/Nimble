#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


typedef NS_ENUM(NSInteger, SCDSvgAspectRatio);
typedef NS_ENUM(NSInteger, SCDSvgBoxAlignment);


/*PROTECTED REGION ID(54ea9b504cb4f2f99aa6645e308b909b) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@protocol SCDSvgAlignmentElement <EObject>


@property(nonatomic) SCDSvgAspectRatio preserveAspectRatio;

@property(nonatomic) SCDSvgBoxAlignment alignment;


/*PROTECTED REGION ID(35c973ab93c1910f8fc8fd6143685418) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
