#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@class SCDLatticeOpenUrlHandler;
@class SCDLatticeApplicationEventHandler;
@class SCDGraphicsDimension;

typedef NS_ENUM(NSInteger, SCDLatticeScreenOrientation);


/*PROTECTED REGION ID(611743a8dbb55f5ec035c198e755de69) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDLatticeSystem : EObject


@property(nonatomic, readonly, getter=isStatusBarVisible) BOOL statusBarVisible;

@property(nonatomic, readonly) SCDLatticeScreenOrientation screenOrientation;

@property(nonatomic) SCDLatticeOpenUrlHandler* _Nullable onOpenUrl;

@property(nonatomic)
    SCDLatticeApplicationEventHandler* _Nullable onEnterBackground;

@property(nonatomic)
    SCDLatticeApplicationEventHandler* _Nullable onEnterForeground;

@property(nonatomic)
    SCDLatticeApplicationEventHandler* _Nullable onKeyboardShow;


- (NSString* _Nonnull)pathForResource:(NSString* _Nonnull)resourceName;

- (NSString* _Nonnull)getCurrentDirectory;

- (SCDGraphicsDimension* _Nonnull)getScreenSize;

- (NSString* _Nonnull)pathForDocument:(NSString* _Nonnull)resourceName;

- (void)openUrl:(NSString* _Nonnull)url;

- (void)exit;

- (void)hideKeyboard;


/*PROTECTED REGION ID(5128cae299e4a3dda97331b276146bfd) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
