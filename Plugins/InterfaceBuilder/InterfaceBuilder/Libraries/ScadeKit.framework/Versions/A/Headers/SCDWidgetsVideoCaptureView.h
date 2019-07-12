#import <Foundation/Foundation.h>

#import <ScadeKit/SCDWidgetsNativeWidget.h>


@class SCDWidgetsVideoCaptureHandler;
@class SCDWidgetsNativeWidget;


/*PROTECTED REGION ID(6ee9195576653af78cf1d5d22489f971) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDWidgetsVideoCaptureView : SCDWidgetsNativeWidget


@property(nonatomic)
    SCDWidgetsVideoCaptureHandler* _Nullable videoCaptureHandler;

@property(nonatomic) long framePerSecond;


- (void)start;

- (void)stop;


/*PROTECTED REGION ID(2f81b604421ab762b8cb12fd9e44d130) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
