#import <Foundation/Foundation.h>

#import <ScadeKit/ENamedElement.h>


@class EPackage;
@class ETypeParameter;
@class ENamedElement;


/*PROTECTED REGION ID(e9581ecfd11aaa26d3122c195faba6e2) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface EClassifier : ENamedElement


@property(nonatomic) NSString* _Nonnull instanceClassName;

@property(nonatomic, readonly) id _Nullable defaultValue;

@property(nonatomic) NSString* _Nonnull instanceTypeName;

@property(nonatomic, readonly) EPackage* _Nullable ePackage;

@property(nonatomic) NSArray<ETypeParameter*>* _Nonnull eTypeParameters;


- (BOOL)isInstance:(id _Nullable)object;

- (long)getClassifierID;


/*PROTECTED REGION ID(f3f7711c884046f817d639244a234274) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
