#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


/*PROTECTED REGION ID(3e7fcd8e934e5cec8ece99c7a90ec200) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDServiceParamBinding : EObject


@property(nonatomic) NSString* _Nonnull paramName;

@property(nonatomic) NSString* _Nonnull value;


- (NSString* _Nonnull)trimStringValue:(long)size;


/*PROTECTED REGION ID(944122bac5c20cc31fb931793e38a6db) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
