#import <Foundation/Foundation.h>

#import <ScadeKit/SCDSvgElement.h>


@protocol SCDSvgAnimatable;
@protocol SCDSvgElement;

@class SCDSvgOnCompleteHandler;


/*PROTECTED REGION ID(c8817d702b4cf5456268105dcac11b20) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDSvgAnimation : EObject <SCDSvgElement>


@property(nonatomic) float delay;

@property(nonatomic) float duration;

@property(nonatomic) long repeatCount;

@property(nonatomic) SCDSvgOnCompleteHandler* _Nullable onComplete;

@property(nonatomic, getter=isDeleteOnComplete) BOOL deleteOnComplete;

@property(nonatomic, readonly) id<SCDSvgAnimatable> _Nullable animatable;


/*PROTECTED REGION ID(eee37f09f3a29645b81f7c37688530c4) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
