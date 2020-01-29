#import <Foundation/Foundation.h>

#import <ScadeKit/SCDWidgetsNativeWidget.h>


@class SCDWidgetsLoadEventHandler;
@class SCDWidgetsShouldLoadEventHandler;
@class SCDWidgetsLoadFailedEventHandler;
@class SCDWidgetsNativeWidget;
@class SCDWidgetsWebViewEvalHandler;


/*PROTECTED REGION ID(d06a67490ee80dd63bade905cb10f988) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDWidgetsWebView : SCDWidgetsNativeWidget


@property(nonatomic, readonly) NSString* _Nonnull url;

@property(nonatomic) NSArray<SCDWidgetsLoadEventHandler*>* _Nonnull onLoaded;

@property(nonatomic)
    NSArray<SCDWidgetsShouldLoadEventHandler*>* _Nonnull onShouldLoad;

@property(nonatomic)
    NSArray<SCDWidgetsLoadFailedEventHandler*>* _Nonnull onLoadFailed;


- (void)load:(NSString* _Nonnull)url;

- (void)eval:(NSString* _Nonnull)script
    onSuccess:(SCDWidgetsWebViewEvalHandler* _Nullable)onSuccess
      onError:(SCDWidgetsWebViewEvalHandler* _Nullable)onError;


/*PROTECTED REGION ID(3a3dc42b54def22bff9ae5276c3f6754) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
