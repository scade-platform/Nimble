#import <Foundation/Foundation.h>

#import <ScadeKit/SCDWidgetsClickable.h>
#import <ScadeKit/SCDWidgetsWidget.h>


@protocol SCDWidgetsClickable;

@class SCDWidgetsWidget;


/*PROTECTED REGION ID(a2f88dcdb7cf5f178cf9bc77e3e9c5d2) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDWidgetsCheckbox : SCDWidgetsWidget <SCDWidgetsClickable>


@property(nonatomic, getter=isChecked) BOOL checked;


/*PROTECTED REGION ID(0a049afba630def46195f5d36bcf2aec) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
