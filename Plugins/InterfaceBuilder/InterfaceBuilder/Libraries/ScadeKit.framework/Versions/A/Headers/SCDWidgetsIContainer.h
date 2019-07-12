#import <Foundation/Foundation.h>

#import <ScadeKit/SCDWidgetsLayoutable.h>
#import <ScadeKit/SCDWidgetsClickable.h>


@protocol SCDWidgetsLayoutable;
@protocol SCDWidgetsClickable;
@protocol SCDLayoutNode;

@class SCDWidgetsWidget;


/*PROTECTED REGION ID(b7a447028c1c2b1c660253b4c7f75e94) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@protocol SCDWidgetsIContainer <SCDWidgetsLayoutable, SCDWidgetsClickable>


@property(nonatomic) NSArray<SCDWidgetsWidget*>* _Nonnull children;


- (SCDWidgetsWidget* _Nullable)getWidgetByName:(NSString* _Nonnull)name;


/*PROTECTED REGION ID(c8c791bc92489911198d5375dfc9454a) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
