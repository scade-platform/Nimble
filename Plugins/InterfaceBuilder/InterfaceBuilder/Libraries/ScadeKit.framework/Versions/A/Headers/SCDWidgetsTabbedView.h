#import <Foundation/Foundation.h>

#import <ScadeKit/SCDWidgetsLayoutable.h>
#import <ScadeKit/SCDWidgetsWidget.h>


@protocol SCDWidgetsLayoutable;
@protocol SCDLayoutNode;

@class SCDWidgetsTabButtonsPanel;
@class SCDWidgetsTabContentPanel;
@class SCDWidgetsTabButton;
@class SCDWidgetsWidget;


/*PROTECTED REGION ID(883e26e6483a06e4ddcc8b1ea3ad0b00) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDWidgetsTabbedView : SCDWidgetsWidget <SCDWidgetsLayoutable>


@property(nonatomic) SCDWidgetsTabButtonsPanel* _Nullable tabButtonsPanel;

@property(nonatomic) SCDWidgetsTabContentPanel* _Nullable contentPanel;

@property(nonatomic) long activeIndex;

@property(nonatomic, readonly) SCDWidgetsTabButton* _Nullable activeButton;

@property(nonatomic, readonly) SCDWidgetsWidget* _Nullable activeTab;

@property(nonatomic, getter=isButtonsOnTop) BOOL buttonsOnTop;

@property(nonatomic, getter=isSwitchOnSwipe) BOOL switchOnSwipe;

@property(nonatomic, getter=isShowButtons) BOOL showButtons;


- (SCDWidgetsWidget* _Nullable)getTabFor:(long)index;

- (SCDWidgetsWidget* _Nullable)getTabForButton:
    (SCDWidgetsTabButton* _Nullable)tabButton;


/*PROTECTED REGION ID(707fc505276f4e8b6d42929037d1ac2e) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
