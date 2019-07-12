#import <Foundation/Foundation.h>

#import <ScadeKit/EModelElement.h>


@class EModelElement;
@class EObject;


/*PROTECTED REGION ID(b2e42c4199ebc0ccb16bb81c489500be) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface EAnnotation : EModelElement


@property(nonatomic) NSString* _Nonnull source;

@property(nonatomic, readonly) EModelElement* _Nullable eModelElement;

@property(nonatomic) NSArray<EObject*>* _Nonnull contents;

@property(nonatomic) NSArray<EObject*>* _Nonnull references;


/*PROTECTED REGION ID(677d73532ffa9432d5f85b7422fcf6dd) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
