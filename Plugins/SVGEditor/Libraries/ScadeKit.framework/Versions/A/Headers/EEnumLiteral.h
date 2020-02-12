#import <Foundation/Foundation.h>

#import <ScadeKit/ENamedElement.h>


@class EEnum;
@class ENamedElement;


/*PROTECTED REGION ID(a7f17d702b8e90cefaecfd34dbd92ca1) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface EEnumLiteral : ENamedElement


@property(nonatomic) long value;

@property(nonatomic) NSString* _Nonnull literal;

@property(nonatomic, readonly) EEnum* _Nullable eEnum;


/*PROTECTED REGION ID(b430f905e9ac15f7a4dbe2d5f0eb04f2) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
