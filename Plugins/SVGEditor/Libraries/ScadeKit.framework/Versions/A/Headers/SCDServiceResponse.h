#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


typedef NS_ENUM(NSInteger, SCDServiceResponseType);


/*PROTECTED REGION ID(9f96577837116e0035f7554d54d36863) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDServiceResponse : EObject


@property(nonatomic) SCDServiceResponseType type;

@property(nonatomic) NSString* _Nonnull content;


/*PROTECTED REGION ID(9b2211febb6931ffe3b9dc40744743b7) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
