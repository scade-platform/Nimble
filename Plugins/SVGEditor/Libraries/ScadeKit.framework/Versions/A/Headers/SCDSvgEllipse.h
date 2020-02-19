#import <Foundation/Foundation.h>

#import <ScadeKit/SCDSvgShape.h>


@protocol SCDSvgShape;

@class SCDSvgUnit;


/*PROTECTED REGION ID(8c972cfeddfe003a64318a22a7101618) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDSvgEllipse : EObject <SCDSvgShape>


@property(nonatomic) SCDSvgUnit* _Nonnull cx;

@property(nonatomic) SCDSvgUnit* _Nonnull cy;

@property(nonatomic) SCDSvgUnit* _Nonnull rx;

@property(nonatomic) SCDSvgUnit* _Nonnull ry;


/*PROTECTED REGION ID(4b5ff24a1c157e66980c6c5e909858fb) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
