#import <Foundation/Foundation.h>

#import <ScadeKit/SCDWidgetsLayoutable.h>
#import <ScadeKit/SCDWidgetsWidget.h>


@protocol SCDWidgetsLayoutable;
@protocol SCDLayoutNode;

@class SCDWidgetsListTemplate;
@class SCDWidgetsListElement;
@class SCDWidgetsItemSelectedEventHandler;
@class SCDWidgetsListElementProvider;
@class SCDWidgetsWidget;


/*PROTECTED REGION ID(7361c0941bc291e32bee28661fd1342c) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDWidgetsList : SCDWidgetsWidget <SCDWidgetsLayoutable>


@property(nonatomic) NSArray<SCDWidgetsListElement*>* _Nonnull elements;

@property(nonatomic) NSArray<id>* _Nonnull items;

@property(nonatomic)
    NSArray<SCDWidgetsItemSelectedEventHandler*>* _Nonnull onItemSelected;

@property(nonatomic) SCDWidgetsListElementProvider* _Nullable elementProvider;


/*PROTECTED REGION ID(6534581bc5133b7eb101bff8b0bcc04a) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
