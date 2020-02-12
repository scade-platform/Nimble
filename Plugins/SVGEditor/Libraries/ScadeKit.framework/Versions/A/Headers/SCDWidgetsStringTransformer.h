#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


/*PROTECTED REGION ID(5b0d9d4bde6074761d63dcc40e918766) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDWidgetsStringTransformer : EObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;

- (instancetype _Nonnull)initWithHandler:
    (nonnull NSString* _Nonnull (^)(id _Nullable))_ NS_DESIGNATED_INITIALIZER;


- (NSString* _Nonnull)invoke:(id _Nullable)arg;


/*PROTECTED REGION ID(21232801760a8afc20dcb5c2964d3ea2) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
