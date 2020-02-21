#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@class SCDSvgColor;
@class SCDSvgPattern;
@class SCDSvgClipPath;

typedef NS_ENUM(NSInteger, SCDSvgFillRule);
typedef NS_ENUM(NSInteger, SCDSvgLineJoin);


/*PROTECTED REGION ID(6da5ae2ca6573c80588c1f1d2cd3aee8) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@protocol SCDSvgStylable <EObject>


@property(nonatomic) SCDSvgColor* _Nullable fill;

@property(nonatomic) SCDSvgFillRule fillRule;

@property(nonatomic) SCDSvgColor* _Nullable fillObject;

@property(nonatomic) float fillOpacity;

@property(nonatomic) SCDSvgColor* _Nullable stroke;

@property(nonatomic) float strokeWidth;

@property(nonatomic) float strokeOpacity;

@property(nonatomic) SCDSvgLineJoin strokeLineJoin;

@property(nonatomic) float strokeDashOffset;

@property(nonatomic) float opacity;

@property(nonatomic) SCDSvgPattern* _Nullable pattern;

@property(nonatomic) SCDSvgClipPath* _Nullable clipPath;


/*PROTECTED REGION ID(c00b8eaf8eb559725ac73c5e81bd3da1) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
