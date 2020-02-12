#import <Foundation/Foundation.h>

#import <ScadeKit/SCDSvgShape.h>


@protocol SCDSvgShape;

@class SCDSvgUnit;


/*PROTECTED REGION ID(5124e3d4698a3e22524b786777619dcc) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDSvgLine : EObject <SCDSvgShape>


@property(nonatomic) SCDSvgUnit* _Nonnull x1;

@property(nonatomic) SCDSvgUnit* _Nonnull y1;

@property(nonatomic) SCDSvgUnit* _Nonnull x2;

@property(nonatomic) SCDSvgUnit* _Nonnull y2;


/*PROTECTED REGION ID(d551b2723f14ca37955849d3520c55e1) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
