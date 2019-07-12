#import <Foundation/Foundation.h>

#import <ScadeKit/SCDSvgContainerElement.h>
#import <ScadeKit/SCDSvgDrawable.h>
#import <ScadeKit/SCDSvgStylable.h>
#import <ScadeKit/SCDSvgFontStyleable.h>


@protocol SCDSvgDrawable;
@protocol SCDSvgStylable;
@protocol SCDSvgFontStyleable;

@class SCDSvgContainerElement;


/*PROTECTED REGION ID(78b9d6f590cf951aabb274b0a3a4c953) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDSvgGroup : SCDSvgContainerElement <SCDSvgDrawable, SCDSvgStylable,
                                                 SCDSvgFontStyleable>


/*PROTECTED REGION ID(de71a5b6b1a3abadbf809b868a852bcd) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
