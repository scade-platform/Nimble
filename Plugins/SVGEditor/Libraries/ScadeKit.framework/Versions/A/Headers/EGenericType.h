#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@class EClassifier;
@class ETypeParameter;


/*PROTECTED REGION ID(484a929bed2fc26331a8fdff238d9567) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface EGenericType : EObject


@property(nonatomic) EGenericType* _Nullable eUpperBound;

@property(nonatomic) NSArray<EGenericType*>* _Nonnull eTypeArguments;

@property(nonatomic, readonly) EClassifier* _Nonnull eRawType;

@property(nonatomic) EGenericType* _Nullable eLowerBound;

@property(nonatomic) ETypeParameter* _Nullable eTypeParameter;

@property(nonatomic) EClassifier* _Nullable eClassifier;


/*PROTECTED REGION ID(a3e5d0b92e9bfb5142b8d228b821655b) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
