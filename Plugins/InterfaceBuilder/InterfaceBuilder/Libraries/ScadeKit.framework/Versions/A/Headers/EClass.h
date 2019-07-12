#import <Foundation/Foundation.h>

#import <ScadeKit/EClassifier.h>


@class EOperation;
@class EAttribute;
@class EReference;
@class EStructuralFeature;
@class EGenericType;
@class EClassifier;


/*PROTECTED REGION ID(6fdb91c092c119d46415dd954dc9169f) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface EClass : EClassifier


@property(nonatomic, getter=isAbstract) BOOL abstract;

@property(nonatomic) NSArray<EClass*>* _Nonnull eSuperTypes;

@property(nonatomic) NSArray<EOperation*>* _Nonnull eOperations;

@property(nonatomic, readonly) NSArray<EAttribute*>* _Nonnull eAllAttributes;

@property(nonatomic, readonly) NSArray<EReference*>* _Nonnull eAllReferences;

@property(nonatomic, readonly) NSArray<EReference*>* _Nonnull eReferences;

@property(nonatomic, readonly) NSArray<EAttribute*>* _Nonnull eAttributes;

@property(nonatomic, readonly) NSArray<EReference*>* _Nonnull eAllContainments;

@property(nonatomic, readonly) NSArray<EOperation*>* _Nonnull eAllOperations;

@property(nonatomic, readonly)
    NSArray<EStructuralFeature*>* _Nonnull eAllStructuralFeatures;

@property(nonatomic, readonly) NSArray<EClass*>* _Nonnull eAllSuperTypes;

@property(nonatomic, readonly) EAttribute* _Nullable eIDAttribute;

@property(nonatomic) NSArray<EStructuralFeature*>* _Nonnull eStructuralFeatures;

@property(nonatomic) NSArray<EGenericType*>* _Nonnull eGenericSuperTypes;

@property(nonatomic, readonly)
    NSArray<EGenericType*>* _Nonnull eAllGenericSuperTypes;


- (BOOL)isSuperTypeOf:(EClass* _Nullable)someClass;

- (long)getFeatureID:(EStructuralFeature* _Nullable)feature;

- (EStructuralFeature* _Nullable)getEStructuralFeatureWithFeatureID:
    (long)featureID SWIFT_COMPILE_NAME("getEStructuralFeature(featureID:)");

- (EStructuralFeature* _Nullable)getEStructuralFeatureWithFeatureName:
    (NSString* _Nonnull)featureName
    SWIFT_COMPILE_NAME("getEStructuralFeature(featureName:)");

- (long)getFeatureCount;

- (long)getOperationID:(EOperation* _Nullable)operation;

- (EOperation* _Nullable)getEOperationWithOperationID:(long)operationID
    SWIFT_COMPILE_NAME("getEOperation(operationID:)");

- (EOperation* _Nullable)getEOperationWithOperationName:
    (NSString* _Nonnull)operationName
    SWIFT_COMPILE_NAME("getEOperation(operationName:)");

- (long)getOperationCount;

- (EOperation* _Nullable)getOverride:(EOperation* _Nullable)operation;


/*PROTECTED REGION ID(42e48b6dc5777ea41a183d9688b570f9) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
