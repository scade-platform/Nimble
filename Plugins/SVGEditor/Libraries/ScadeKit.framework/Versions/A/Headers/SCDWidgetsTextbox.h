#import <Foundation/Foundation.h>

#import <ScadeKit/SCDWidgetsTextWidget.h>


@class SCDWidgetsTextChangeEventHandler;
@class SCDWidgetsEditFinishEventHandler;
@class SCDWidgetsTextWidget;

typedef NS_ENUM(NSInteger, SCDWidgetsKeyboard);
typedef NS_ENUM(NSInteger, SCDWidgetsKeyboardType);


/*PROTECTED REGION ID(bf159aa99dcb5ee3478d9ad89b665c4f) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDWidgetsTextbox : SCDWidgetsTextWidget


@property(nonatomic) NSString* _Nonnull placeholder;

@property(nonatomic) long tabIndex;

@property(nonatomic) SCDWidgetsKeyboard keyboard;

@property(nonatomic) SCDWidgetsKeyboardType keyboardType;

@property(nonatomic)
    NSArray<SCDWidgetsTextChangeEventHandler*>* _Nonnull onTextChange;

@property(nonatomic)
    NSArray<SCDWidgetsEditFinishEventHandler*>* _Nonnull onEditFinish;

@property(nonatomic, getter=isSecure) BOOL secure;


- (void)setFocus;


/*PROTECTED REGION ID(6fd37ffe3355d07877649ec6846b83c4) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
