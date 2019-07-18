#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@protocol SCDLatticeView;

@class SCDWidgetsPage;
@class SCDLatticeNavigation;


/*PROTECTED REGION ID(16b3e19f6d922266d055c5856448ab85) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDLatticePageAdapter : EObject


@property(nonatomic, readonly) SCDWidgetsPage* _Nullable page;

@property(nonatomic, readonly) id<SCDLatticeView> _Nullable view;

@property(nonatomic, readonly) SCDLatticeNavigation* _Nullable navigation;


- (void)load:(NSString* _Nonnull)path;

- (void)activate:(id<SCDLatticeView> _Nullable)view;

- (void)show:(id<SCDLatticeView> _Nullable)view;

- (void)show:(id<SCDLatticeView> _Nullable)view data:(id _Nullable)data;

- (void)hide;


/*PROTECTED REGION ID(3f1da8ca13080fcf7a1022b1ebc85f51) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
