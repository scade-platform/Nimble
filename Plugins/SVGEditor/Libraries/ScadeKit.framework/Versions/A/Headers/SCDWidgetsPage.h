#import <Foundation/Foundation.h>

#import <ScadeKit/SCDWidgetsContainer.h>


@class SCDWidgetsEnterEventHandler;
@class SCDWidgetsExitEventHandler;
@class EObject;
@class EClass;
@class SCDWidgetsContainer;
@class SCDWidgetsWidget;


/*PROTECTED REGION ID(d0896e6f7c44ccd48d144476fc04a683) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDWidgetsPage : SCDWidgetsContainer


@property(nonatomic) NSArray<SCDWidgetsEnterEventHandler*>* _Nonnull onEnter;

@property(nonatomic) NSArray<SCDWidgetsExitEventHandler*>* _Nonnull onExit;

@property(nonatomic) EObject* _Nullable adapter;

@property(nonatomic) EClass* _Nullable adapterClass;


- (NSArray<SCDWidgetsWidget*>* _Nonnull)getAllWidgets;


/*PROTECTED REGION ID(556fba5467dfd1322e5d5ff3e6d17a52) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
