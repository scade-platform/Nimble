#import <Foundation/Foundation.h>

#import <ScadeKit/SCDWidgetsContainer.h>


@class SCDWidgetsTabbedView;
@class SCDWidgetsTabButtonsPanel;
@class SCDWidgetsContainer;


/*PROTECTED REGION ID(30c0835538ae610a34a54095ccb4f69c) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDWidgetsTabContentPanel : SCDWidgetsContainer


@property(nonatomic, readonly) SCDWidgetsTabbedView* _Nullable ownerView;

@property(nonatomic, readonly)
    SCDWidgetsTabButtonsPanel* _Nullable tabButtonsPanel;


/*PROTECTED REGION ID(1c73a819b4a19338128033e2eb1fc83c) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
