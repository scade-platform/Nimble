#import <Foundation/Foundation.h>

#import <ScadeKit/SCDSvgFontStyleable.h>
#import <ScadeKit/SCDSvgTextSegment.h>


@protocol SCDSvgFontStyleable;
@protocol SCDSvgTextSegment;


typedef NS_ENUM(NSInteger, SCDSvgTextAnchor);
typedef NS_ENUM(NSInteger, SCDSvgTextAlignmentBaseline);
typedef NS_ENUM(NSInteger, SCDSvgTextAlignment);


/*PROTECTED REGION ID(a3b3da05cc5162803a653e95dd8a306b) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@protocol SCDSvgTextElement <SCDSvgFontStyleable, SCDSvgTextSegment>


@property(nonatomic) SCDSvgTextAnchor anchor;

@property(nonatomic) SCDSvgTextAlignmentBaseline alignmentBaseline;

@property(nonatomic) SCDSvgTextAlignment alignment;


/*PROTECTED REGION ID(5763f0fa05cca3187bf04e70b3b6912d) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
