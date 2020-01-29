#import <Foundation/Foundation.h>

#import <ScadeKit/SCDWidgetsContainer.h>


@class SCDWidgetsTabbedView;
@class SCDWidgetsTabContentPanel;
@class SCDWidgetsContainer;


/*PROTECTED REGION ID(cee30f11103c97fd2c826935dfb00ec4) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDWidgetsTabButtonsPanel : SCDWidgetsContainer


@property(nonatomic, readonly) SCDWidgetsTabbedView* _Nullable ownerView;

@property(nonatomic, readonly)
    SCDWidgetsTabContentPanel* _Nullable contentPanel;


/*PROTECTED REGION ID(50cb5c0cfd356d2c9f5c57e77c880a0c) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
