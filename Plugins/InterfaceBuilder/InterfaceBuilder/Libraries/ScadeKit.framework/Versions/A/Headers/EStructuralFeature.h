#import <Foundation/Foundation.h>

#import <ScadeKit/ETypedElement.h>


@class EClass;
@class ETypedElement;


/*PROTECTED REGION ID(27c6d01340830ad730cda6f04e1472d2) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface EStructuralFeature : ETypedElement


@property(nonatomic, getter=isChangeable) BOOL changeable;

@property(nonatomic, getter=isTransient) BOOL transient;

@property(nonatomic) NSString* _Nonnull defaultValueLiteral;

@property(nonatomic, readonly) id _Nullable defaultValue;

@property(nonatomic, getter=isUnsettable) BOOL unsettable;

@property(nonatomic, getter=isDerived) BOOL derived;

@property(nonatomic, readonly) EClass* _Nullable eContainingClass;


- (long)getFeatureID;


/*PROTECTED REGION ID(25883f41bb1940b1f8bf9470cb60416e) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
