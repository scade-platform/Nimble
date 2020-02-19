#import <Foundation/Foundation.h>

#import <ScadeKit/SCDWidgetsWidget.h>


@class SCDWidgetsTabButtonsPanel;
@class SCDWidgetsTabbedView;
@class SCDWidgetsWidget;


/*PROTECTED REGION ID(9452273daab17482727eaf04cd664160) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDWidgetsTabButton : SCDWidgetsWidget


@property(nonatomic, getter=isActive) BOOL active;

@property(nonatomic, readonly)
    SCDWidgetsTabButtonsPanel* _Nullable tabButtonsPanel;

@property(nonatomic, readonly) SCDWidgetsTabbedView* _Nullable tabbedView;

@property(nonatomic) NSString* _Nonnull text;


- (long)getButtonIndex;


/*PROTECTED REGION ID(d37f29fe0745b427d54f3730eff73394) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
