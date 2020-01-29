#import <Foundation/Foundation.h>

#import <ScadeKit/ETypedElement.h>


@class EClass;
@class ETypeParameter;
@class EParameter;
@class EClassifier;
@class EGenericType;
@class ETypedElement;


/*PROTECTED REGION ID(a9d0fcf0dc2ebdb220b5530ec4570b63) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface EOperation : ETypedElement


@property(nonatomic, readonly) EClass* _Nullable eContainingClass;

@property(nonatomic) NSArray<ETypeParameter*>* _Nonnull eTypeParameters;

@property(nonatomic) NSArray<EParameter*>* _Nonnull eParameters;

@property(nonatomic) NSArray<EClassifier*>* _Nonnull eExceptions;

@property(nonatomic) NSArray<EGenericType*>* _Nonnull eGenericExceptions;


- (long)getOperationID;

- (BOOL)isOverrideOf:(EOperation* _Nullable)someOperation;


/*PROTECTED REGION ID(d845323c1c79da7f33cb0ce3e9a6f26e) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
