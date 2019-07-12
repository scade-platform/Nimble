#import <Foundation/Foundation.h>

#import <ScadeKit/SCDSvgDrawable.h>
#import <ScadeKit/SCDSvgStylable.h>


@protocol SCDSvgDrawable;
@protocol SCDSvgStylable;

@class SCDSvgUnit;


/*PROTECTED REGION ID(951d868d5d16912e56216be8793891bf) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDSvgUse : EObject <SCDSvgDrawable, SCDSvgStylable>


@property(nonatomic) id<SCDSvgDrawable> _Nullable reference;

@property(nonatomic) NSString* _Nonnull xhref;

@property(nonatomic) SCDSvgUnit* _Nonnull x;

@property(nonatomic) SCDSvgUnit* _Nonnull y;

@property(nonatomic) SCDSvgUnit* _Nonnull width;

@property(nonatomic) SCDSvgUnit* _Nonnull height;


/*PROTECTED REGION ID(d021d5f00864a77db4356882add7d235) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
