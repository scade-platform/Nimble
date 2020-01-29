#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, SCDWidgetsNavigationBarButtonType) {
  SCDWidgetsNavigationBarButtonTypeBack = 0,
  SCDWidgetsNavigationBarButtonTypeExtra = 1
};
typedef NS_ENUM(NSInteger, SCDWidgetsDataWheelAlignment) {
  SCDWidgetsDataWheelAlignmentStart = 0,
  SCDWidgetsDataWheelAlignmentMiddle = 1,
  SCDWidgetsDataWheelAlignmentEnd = 2
};
typedef NS_ENUM(NSInteger, SCDWidgetsKeyboard) {
  SCDWidgetsKeyboardResize = 0,
  SCDWidgetsKeyboardOntop = 1
};
typedef NS_ENUM(NSInteger, SCDWidgetsKeyboardType) {
  SCDWidgetsKeyboardTypeAlphabetic = 0,
  SCDWidgetsKeyboardTypeNumber = 1
};
typedef NS_ENUM(NSInteger, SCDWidgetsBaselineAlignment) {
  SCDWidgetsBaselineAlignmentMiddle = 0,
  SCDWidgetsBaselineAlignmentAlphabetic = 1,
  SCDWidgetsBaselineAlignmentHanging = 2
};


typedef NS_ENUM(NSInteger, SCDWidgetsMapType) {
  SCDWidgetsMapTypeStandard = 0,
  SCDWidgetsMapTypeSatellite = 1,
  SCDWidgetsMapTypeHybrid = 2
};


#import <ScadeKit/SCDWidgetsIControl.h>

#import <ScadeKit/SCDWidgetsIVisualControl.h>

#import <ScadeKit/SCDWidgetsLayoutable.h>

#import <ScadeKit/SCDWidgetsIContainer.h>

#import <ScadeKit/SCDWidgetsWidget.h>

#import <ScadeKit/SCDWidgetsContainer.h>

#import <ScadeKit/SCDWidgetsPage.h>

#import <ScadeKit/SCDWidgetsTextWidget.h>

#import <ScadeKit/SCDWidgetsButton.h>

#import <ScadeKit/SCDWidgetsLabel.h>

#import <ScadeKit/SCDWidgetsTextbox.h>

#import <ScadeKit/SCDWidgetsCheckbox.h>

#import <ScadeKit/SCDWidgetsImage.h>

#import <ScadeKit/SCDWidgetsNavigationBar.h>

#import <ScadeKit/SCDWidgetsListView.h>

#import <ScadeKit/SCDWidgetsGridView.h>

#import <ScadeKit/SCDWidgetsTabbedView.h>

#import <ScadeKit/SCDWidgetsTabContentPanel.h>

#import <ScadeKit/SCDWidgetsToolBar.h>

#import <ScadeKit/SCDWidgetsTabButtonsPanel.h>

#import <ScadeKit/SCDWidgetsToolBarItem.h>

#import <ScadeKit/SCDWidgetsTabButton.h>

#import <ScadeKit/SCDWidgetsListElement.h>

#import <ScadeKit/SCDWidgetsList.h>

#import <ScadeKit/SCDWidgetsAlphabeticalList.h>

#import <ScadeKit/SCDWidgetsListTemplate.h>

#import <ScadeKit/SCDWidgetsDatePicker.h>

#import <ScadeKit/SCDWidgetsDataPicker.h>

#import <ScadeKit/SCDWidgetsDataWheel.h>

#import <ScadeKit/SCDWidgetsRowView.h>

#import <ScadeKit/SCDWidgetsStringTransformer.h>

#import <ScadeKit/SCDWidgetsSlider.h>

#import <ScadeKit/SCDWidgetsSliderLine.h>

#import <ScadeKit/SCDWidgetsCustomWidget.h>

#import <ScadeKit/SCDWidgetsSidebar.h>

#import <ScadeKit/SCDWidgetsListElementProvider.h>


#import <ScadeKit/SCDWidgetsEvent.h>

#import <ScadeKit/SCDWidgetsEventHandler.h>

#import <ScadeKit/SCDWidgetsItemEvent.h>

#import <ScadeKit/SCDWidgetsItemSelectedEvent.h>

#import <ScadeKit/SCDWidgetsItemSelectedEventHandler.h>

#import <ScadeKit/SCDWidgetsNavigationEvent.h>

#import <ScadeKit/SCDWidgetsEnterEvent.h>

#import <ScadeKit/SCDWidgetsEnterEventHandler.h>

#import <ScadeKit/SCDWidgetsExitEvent.h>

#import <ScadeKit/SCDWidgetsExitEventHandler.h>

#import <ScadeKit/SCDWidgetsClickable.h>

#import <ScadeKit/SCDWidgetsTextChangeEvent.h>

#import <ScadeKit/SCDWidgetsTextChangeEventHandler.h>

#import <ScadeKit/SCDWidgetsSlideLineEvent.h>

#import <ScadeKit/SCDWidgetsSlideLineEventHandler.h>

#import <ScadeKit/SCDWidgetsSlideEvent.h>

#import <ScadeKit/SCDWidgetsSlideEventHandler.h>

#import <ScadeKit/SCDWidgetsEditFinishEvent.h>

#import <ScadeKit/SCDWidgetsEditFinishEventHandler.h>

#import <ScadeKit/SCDWidgetsLoadEvent.h>

#import <ScadeKit/SCDWidgetsLoadEventHandler.h>

#import <ScadeKit/SCDWidgetsShouldLoadEventHandler.h>

#import <ScadeKit/SCDWidgetsLoadFailedEvent.h>

#import <ScadeKit/SCDWidgetsLoadFailedEventHandler.h>

#import <ScadeKit/SCDWidgetsDatePickerEvent.h>

#import <ScadeKit/SCDWidgetsDatePickerEventHandler.h>


#import <ScadeKit/SCDWidgetsTabbedViewLayout.h>

#import <ScadeKit/SCDWidgetsListLayout.h>

#import <ScadeKit/SCDWidgetsSliderLayout.h>


#import <ScadeKit/SCDWidgetsNativeWidget.h>

#import <ScadeKit/SCDWidgetsMapRegion.h>

#import <ScadeKit/SCDWidgetsMapOverlay.h>

#import <ScadeKit/SCDWidgetsMapAnnotation.h>

#import <ScadeKit/SCDWidgetsMapWidget.h>

#import <ScadeKit/SCDWidgetsWebView.h>

#import <ScadeKit/SCDWidgetsWebViewEvalHandler.h>

#import <ScadeKit/SCDWidgetsVideoCaptureView.h>

#import <ScadeKit/SCDWidgetsVideoCaptureHandler.h>
