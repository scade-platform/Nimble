#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@class SCDCoreResource;
@class EObject;


/*PROTECTED REGION ID(48c0e9a5e4d36a4fa503d244b723e77b) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDCoreResourceSet : EObject


@property(nonatomic) NSArray<SCDCoreResource*>* _Nonnull resouces;


- (EObject* _Nullable)getEObject:(NSString* _Nonnull)name;

- (SCDCoreResource* _Nullable)loadResource:(NSString* _Nonnull)name;

- (SCDCoreResource* _Nullable)createResource:(NSString* _Nonnull)name;


/*PROTECTED REGION ID(b5b5b4a31226838d4beac8a8bcad74b6) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
