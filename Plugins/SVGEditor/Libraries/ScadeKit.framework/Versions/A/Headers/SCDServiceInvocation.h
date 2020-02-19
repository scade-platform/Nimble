#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@class SCDServiceRequest;
@class SCDServiceParamBinding;
@class SCDServiceResponse;


/*PROTECTED REGION ID(10dc249fc05cb4c3bef00bc918e59b95) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDServiceInvocation : EObject


@property(nonatomic) SCDServiceRequest* _Nullable request;

@property(nonatomic) NSArray<SCDServiceParamBinding*>* _Nonnull bindings;

@property(nonatomic) SCDServiceResponse* _Nullable response;

@property(nonatomic) NSString* _Nonnull url;


/*PROTECTED REGION ID(28600aebc1c4c275e3e28d86e2264066) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
