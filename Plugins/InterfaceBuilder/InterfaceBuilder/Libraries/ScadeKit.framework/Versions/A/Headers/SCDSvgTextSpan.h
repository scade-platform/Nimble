#import <Foundation/Foundation.h>

#import <ScadeKit/SCDSvgStylable.h>
#import <ScadeKit/SCDSvgElement.h>
#import <ScadeKit/SCDSvgTextElement.h>
#import <ScadeKit/SCDSvgTouchReceiver.h>


@protocol SCDSvgStylable;
@protocol SCDSvgElement;
@protocol SCDSvgTextElement;
@protocol SCDSvgTouchReceiver;

@class SCDSvgUnit;


/*PROTECTED REGION ID(fb5ed76a35682abcd909a4da605da8c6) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDSvgTextSpan : EObject <SCDSvgStylable, SCDSvgElement,
                                     SCDSvgTextElement, SCDSvgTouchReceiver>


@property(nonatomic) SCDSvgUnit* _Nonnull x;

@property(nonatomic) SCDSvgUnit* _Nonnull y;


/*PROTECTED REGION ID(34a4897ebe7a37221297979d677bc682) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
