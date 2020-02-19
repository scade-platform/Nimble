#import <Foundation/Foundation.h>

#import <ScadeKit/ENamedElement.h>


@class EClassifier;
@class EGenericType;
@class ENamedElement;


/*PROTECTED REGION ID(7fc6840e9a7bf67ac5da1f41fd004d18) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface ETypedElement : ENamedElement


@property(nonatomic, getter=isOrdered) BOOL ordered;

@property(nonatomic, getter=isUnique) BOOL unique;

@property(nonatomic) long lowerBound;

@property(nonatomic) long upperBound;

@property(nonatomic, readonly, getter=isMany) BOOL many;

@property(nonatomic, readonly, getter=isRequired) BOOL required;

@property(nonatomic) EClassifier* _Nullable eType;

@property(nonatomic) EGenericType* _Nullable eGenericType;


/*PROTECTED REGION ID(53831686d9cb198918e3866d211ed2f9) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
