#import <Foundation/Foundation.h>

#import <ScadeKit/SCDSvgShape.h>
#import <ScadeKit/SCDSvgTextElement.h>


@protocol SCDSvgTextSegment;
@protocol SCDSvgShape;
@protocol SCDSvgTextElement;

@class SCDSvgUnit;
@class SCDGraphicsDimension;


/*PROTECTED REGION ID(6a9e040138d140c912ceb704db07dfda) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDSvgText : EObject <SCDSvgShape, SCDSvgTextElement>


@property(nonatomic) NSArray<id<SCDSvgTextSegment>>* _Nonnull segments;

@property(nonatomic) SCDSvgUnit* _Nonnull x;

@property(nonatomic) SCDSvgUnit* _Nonnull y;


- (SCDGraphicsDimension* _Nonnull)getTextBounds;


/*PROTECTED REGION ID(cd9f68a5be7c2d9b9b4f79022223d9e0) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
