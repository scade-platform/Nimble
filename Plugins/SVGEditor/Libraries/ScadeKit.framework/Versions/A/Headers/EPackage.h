#import <Foundation/Foundation.h>

#import <ScadeKit/ENamedElement.h>


@class EFactory;
@class EClassifier;
@class ENamedElement;


/*PROTECTED REGION ID(f719ef359850a9a0b473714b67ba90d8) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface EPackage : ENamedElement

- (instancetype _Nonnull)init NS_UNAVAILABLE;

- (instancetype _Nonnull)initWithEFactoryInstance:
    (EFactory* _Nonnull)eFactoryInstance NS_DESIGNATED_INITIALIZER;

@property(nonatomic) NSString* _Nonnull nsURI;

@property(nonatomic) NSString* _Nonnull nsPrefix;

@property(nonatomic) EFactory* _Nonnull eFactoryInstance;

@property(nonatomic) NSArray<EClassifier*>* _Nonnull eClassifiers;

@property(nonatomic) NSArray<EPackage*>* _Nonnull eSubpackages;

@property(nonatomic, readonly) EPackage* _Nullable eSuperPackage;


- (EClassifier* _Nullable)getEClassifier:(NSString* _Nonnull)name;


/*PROTECTED REGION ID(0ef4a58f81ec8ea1be947158797ffad1) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
