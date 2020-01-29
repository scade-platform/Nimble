#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@class SCDNetworkResponseError;


/*PROTECTED REGION ID(139b10f29be0037eb607cffcaacb62c1) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDNetworkErrorHandler : EObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;

- (instancetype _Nonnull)initWithHandler:
    (nonnull void (^)(SCDNetworkResponseError* _Nullable))_
    NS_DESIGNATED_INITIALIZER;


- (void)invoke:(SCDNetworkResponseError* _Nullable)arg;


/*PROTECTED REGION ID(abaa03628ee2b19b8dcb1f015bd41cff) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
