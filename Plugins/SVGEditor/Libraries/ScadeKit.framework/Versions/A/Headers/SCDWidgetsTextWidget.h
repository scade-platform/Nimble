#import <Foundation/Foundation.h>

#import <ScadeKit/SCDWidgetsWidget.h>


@class SCDGraphicsFont;
@class SCDWidgetsWidget;

typedef NS_ENUM(NSInteger, SCDLayoutHorizontalAlignment);
typedef NS_ENUM(NSInteger, SCDWidgetsBaselineAlignment);
typedef NS_ENUM(NSInteger, SCDLayoutVerticalAlignment);


/*PROTECTED REGION ID(7adfcd985e23eea807295aae15f3988a) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDWidgetsTextWidget : SCDWidgetsWidget


@property(nonatomic) NSString* _Nonnull text;

@property(nonatomic, getter=isWrapText) BOOL wrapText;

@property(nonatomic, getter=isMultiline) BOOL multiline;

@property(nonatomic) SCDLayoutHorizontalAlignment horizontalAlignment;

@property(nonatomic) SCDWidgetsBaselineAlignment baselineAlignment;

@property(nonatomic) SCDLayoutVerticalAlignment verticalAlignment;

@property(nonatomic) SCDGraphicsFont* _Nullable font;


/*PROTECTED REGION ID(f9400f76f5cb048908f6c2f0588974bb) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
