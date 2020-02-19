#import <Foundation/Foundation.h>

#import <ScadeKit/EStructuralFeature.h>


@class EClass;
@class EAttribute;
@class EStructuralFeature;


/*PROTECTED REGION ID(df0a56c63da8ad810188062961e1395f) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface EReference : EStructuralFeature


@property(nonatomic, getter=isContainment) BOOL containment;

@property(nonatomic, readonly, getter=isContainer) BOOL container;

@property(nonatomic, getter=isResolveProxies) BOOL resolveProxies;

@property(nonatomic) EReference* _Nullable eOpposite;

@property(nonatomic, readonly) EClass* _Nonnull eReferenceType;

@property(nonatomic) NSArray<EAttribute*>* _Nonnull eKeys;


/*PROTECTED REGION ID(59ca7b7873e34f9fb337b166db4ac8ec) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
