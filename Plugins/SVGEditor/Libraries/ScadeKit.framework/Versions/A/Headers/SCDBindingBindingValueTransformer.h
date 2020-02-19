#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@class SCDBindingBindingValue;


/*PROTECTED REGION ID(cfbc96eaa9fb94eb127693162d702083) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDBindingBindingValueTransformer : EObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;

- (instancetype _Nonnull)initWithHandler:
    (nonnull id _Nullable (^)(SCDBindingBindingValue* _Nullable))_
    NS_DESIGNATED_INITIALIZER;


- (id _Nullable)invoke:(SCDBindingBindingValue* _Nullable)arg;


/*PROTECTED REGION ID(a81e2664a64fdae11d818143b4b44d2f) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
