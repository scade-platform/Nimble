#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


typedef NS_ENUM(NSInteger, SCDSvgFontStyle);
typedef NS_ENUM(NSInteger, SCDSvgTextDecoration);


/*PROTECTED REGION ID(e16a23b9823fe923297c1330de619a57) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@protocol SCDSvgFontStyleable <EObject>


@property(nonatomic) long fontSize;

@property(nonatomic) NSString* _Nonnull fontName;

@property(nonatomic) SCDSvgFontStyle style;

@property(nonatomic) long weight;

@property(nonatomic) SCDSvgTextDecoration decoration;


/*PROTECTED REGION ID(b2d95a1fb56c5d638277b222d35fa1a9) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
