#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@protocol SCDLayoutNode;

@class SCDLayoutLayout;
@class SCDGraphicsDimension;


/*PROTECTED REGION ID(bb2e29e5f77d3211088ba411f8806ff9) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@protocol SCDLayoutILayoutable <EObject>


@property(nonatomic) SCDLayoutLayout* _Nullable layout;

@property(nonatomic) SCDGraphicsDimension* _Nonnull minArea;

@property(nonatomic) SCDGraphicsDimension* _Nonnull maxArea;


- (NSArray<id<SCDLayoutNode>>* _Nonnull)getWidgetsForLayout;


/*PROTECTED REGION ID(39435897b452d337f1cbdf22348fbbca) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
