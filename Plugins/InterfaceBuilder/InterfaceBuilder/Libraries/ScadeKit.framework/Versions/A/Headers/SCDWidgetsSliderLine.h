#import <Foundation/Foundation.h>

#import <ScadeKit/SCDWidgetsWidget.h>


@class SCDWidgetsSlideLineEventHandler;
@class SCDWidgetsWidget;


/*PROTECTED REGION ID(83472dbb9f729d9a524145dec86c6b1d) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDWidgetsSliderLine : SCDWidgetsWidget


@property(nonatomic) long minValue;

@property(nonatomic) long maxValue;

@property(nonatomic) long position;

@property(nonatomic)
    NSArray<SCDWidgetsSlideLineEventHandler*>* _Nonnull onSlide;


/*PROTECTED REGION ID(addfd659de0d93fce35303bf8df587e5) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
