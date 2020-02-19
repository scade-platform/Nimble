#import <Foundation/Foundation.h>

#import <ScadeKit/SCDWidgetsContainer.h>


@protocol SCDWidgetsIContainer;

@class SCDWidgetsContainer;


/*PROTECTED REGION ID(d339398bc69f6a1d5b2174dbc5129fe9) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDWidgetsListElement : SCDWidgetsContainer


@property(nonatomic) id<SCDWidgetsIContainer> _Nullable leftBar;

@property(nonatomic) id<SCDWidgetsIContainer> _Nullable rightBar;

@property(nonatomic, getter=isSelectable) BOOL selectable;


/*PROTECTED REGION ID(ac4ec6f74856b3e8d2c711bcd09a56e1) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
