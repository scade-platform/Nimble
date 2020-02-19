#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@class EAnnotation;


/*PROTECTED REGION ID(efa3ca86c25388cdbc355ff578fc6f8b) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface EModelElement : EObject


@property(nonatomic) NSArray<EAnnotation*>* _Nonnull eAnnotations;


- (EAnnotation* _Nullable)getEAnnotation:(NSString* _Nonnull)source;


/*PROTECTED REGION ID(9c30983a98db90a5f788c80675013711) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
