#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@class SCDWidgetsPage;
@class SCDLatticeSizeChangeHandler;
@class SCDLatticePageAdapter;
@class SCDLatticeNavigation;


/*PROTECTED REGION ID(3747acc3ba8233c393a3fed4b49a4c36) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@protocol SCDLatticeView <EObject>


@property(nonatomic, readonly) SCDWidgetsPage* _Nullable page;

@property(nonatomic)
    NSArray<SCDLatticeSizeChangeHandler*>* _Nonnull onSizeChanged;

@property(nonatomic, readonly) SCDLatticePageAdapter* _Nullable adapter;

@property(nonatomic, readonly) SCDLatticeNavigation* _Nullable navigation;


- (void)show:(SCDWidgetsPage* _Nullable)page;


/*PROTECTED REGION ID(32f92b9ad78247fc3e0c7f6e2e69bcfd) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
