#import <Foundation/Foundation.h>

#import <ScadeKit/EModelElement.h>


@class EPackage;
@class EModelElement;
@class EObject;
@class EClass;
@class EDataType;


/*PROTECTED REGION ID(8985d5e789d9297bd47702c0577e7ef7) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface EFactory : EModelElement

- (instancetype _Nonnull)init NS_UNAVAILABLE;

- (instancetype _Nonnull)initWithEPackage:(EPackage* _Nonnull)ePackage
    NS_DESIGNATED_INITIALIZER;

@property(nonatomic) EPackage* _Nonnull ePackage;


- (EObject* _Nullable)createWithEClass:(EClass* _Nullable)eClass
    SWIFT_COMPILE_NAME("create(eClass:)");

- (EObject* _Nullable)createWithEClassName:(NSString* _Nonnull)eClassName
    SWIFT_COMPILE_NAME("create(eClassName:)");

- (id _Nullable)createFromString:(EDataType* _Nullable)eDataType
                    literalValue:(NSString* _Nonnull)literalValue;

- (NSString* _Nonnull)convertToString:(EDataType* _Nullable)eDataType
                        instanceValue:(id _Nullable)instanceValue;


/*PROTECTED REGION ID(6b867b4476a9d07f63f0466953f0aa6e) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
