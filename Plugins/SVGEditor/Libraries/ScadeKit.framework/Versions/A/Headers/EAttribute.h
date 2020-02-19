#import <Foundation/Foundation.h>

#import <ScadeKit/EStructuralFeature.h>


@class EDataType;
@class EStructuralFeature;


/*PROTECTED REGION ID(e83e4406b11d6bb033b1f63704ede4c3) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface EAttribute : EStructuralFeature


@property(nonatomic, getter=isID) BOOL iD;

@property(nonatomic, readonly) EDataType* _Nonnull eAttributeType;


/*PROTECTED REGION ID(199c1d98e146a7090b22f26f2f2777d8) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
