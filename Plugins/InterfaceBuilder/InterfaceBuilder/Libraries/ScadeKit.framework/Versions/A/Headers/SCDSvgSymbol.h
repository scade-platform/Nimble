#import <Foundation/Foundation.h>

#import <ScadeKit/SCDSvgGroup.h>
#import <ScadeKit/SCDSvgAlignmentElement.h>


@protocol SCDSvgAlignmentElement;

@class SCDSvgGroup;


/*PROTECTED REGION ID(fb3aab3e3d6b66706104aecd2b010048) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDSvgSymbol : SCDSvgGroup <SCDSvgAlignmentElement>


@property(nonatomic) NSString* _Nonnull viewBox;


/*PROTECTED REGION ID(ab658b8dc23a0f068f8bcf32c45e5dd1) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
