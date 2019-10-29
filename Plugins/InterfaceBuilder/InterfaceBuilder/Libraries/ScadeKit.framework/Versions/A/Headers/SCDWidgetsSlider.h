#import <Foundation/Foundation.h>

#import <ScadeKit/SCDWidgetsLayoutable.h>
#import <ScadeKit/SCDWidgetsWidget.h>


@protocol SCDWidgetsLayoutable;
@protocol SCDLayoutNode;

@class SCDWidgetsWidget;
@class SCDWidgetsSlideEventHandler;
@class SCDWidgetsListElementProvider;


/*PROTECTED REGION ID(8f8391967b43a2cfdae008e0b86100dd) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDWidgetsSlider : SCDWidgetsWidget <SCDWidgetsLayoutable>


@property(nonatomic) NSArray<SCDWidgetsWidget*>* _Nonnull elements;

@property(nonatomic) NSArray<id>* _Nonnull items;

@property(nonatomic) NSArray<SCDWidgetsSlideEventHandler*>* _Nonnull onSlide;

@property(nonatomic) long selected;

@property(nonatomic) SCDWidgetsListElementProvider* _Nullable elementProvider;


/*PROTECTED REGION ID(bdb22d9bff2b6f61e924b4910712a763) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
