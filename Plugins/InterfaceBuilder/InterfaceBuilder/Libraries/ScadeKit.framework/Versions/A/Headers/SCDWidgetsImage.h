#import <Foundation/Foundation.h>

#import <ScadeKit/SCDWidgetsWidget.h>
#import <ScadeKit/SCDWidgetsClickable.h>


@protocol SCDWidgetsClickable;

@class SCDWidgetsWidget;


/*PROTECTED REGION ID(a653eeb7c4c665f9b5e7a576923d4629) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDWidgetsImage : SCDWidgetsWidget <SCDWidgetsClickable>


@property(nonatomic) NSString* _Nonnull content;

@property(nonatomic) NSString* _Nonnull url;

@property(nonatomic, getter=isContentPriority) BOOL contentPriority;


/*PROTECTED REGION ID(d0a53cf324c9871f8173a85a26beb746) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
