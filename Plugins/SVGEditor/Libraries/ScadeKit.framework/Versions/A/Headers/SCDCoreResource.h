#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@class EObject;


/*PROTECTED REGION ID(137918a89ff8ab87dde9da9350569cfb) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDCoreResource : EObject


@property(nonatomic) NSArray<EObject*>* _Nonnull contents;


- (EObject* _Nullable)getEObject:(NSString* _Nonnull)name;

- (NSString* _Nonnull)getURI;


/*PROTECTED REGION ID(d7cff587fcb2e3273823b4b001726e6f) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
