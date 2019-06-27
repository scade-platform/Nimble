#import <Cocoa/Cocoa.h>
#import <ScadeKit/ScadeKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PageHighlighter: NSObject

- (void)select:(SCDWidgetsWidget*)widget;

- (void)unselect:(SCDWidgetsWidget*)widget;

@end

NS_ASSUME_NONNULL_END
