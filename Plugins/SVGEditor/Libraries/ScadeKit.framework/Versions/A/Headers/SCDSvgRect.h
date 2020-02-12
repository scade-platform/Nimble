#import <Foundation/Foundation.h>

#import <ScadeKit/SCDSvgShape.h>


@protocol SCDSvgShape;

@class SCDSvgUnit;


/*PROTECTED REGION ID(6ed137b1d9a8b533ab85f32768010c28) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDSvgRect : EObject <SCDSvgShape>


@property(nonatomic) SCDSvgUnit* _Nonnull x;

@property(nonatomic) SCDSvgUnit* _Nonnull y;

@property(nonatomic) SCDSvgUnit* _Nonnull width;

@property(nonatomic) SCDSvgUnit* _Nonnull height;

@property(nonatomic) SCDSvgUnit* _Nonnull rx;

@property(nonatomic) SCDSvgUnit* _Nonnull ry;


/*PROTECTED REGION ID(b8856510bbef1737eb88e8f59c18593b) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
