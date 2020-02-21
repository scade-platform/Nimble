#import <Foundation/Foundation.h>

#import <ScadeKit/EOperation.h>


@class EOperation;

typedef NS_ENUM(NSInteger, SCDServiceResponseType);


/*PROTECTED REGION ID(63b41b3766f2f4127bd0bbb16fce6ee9) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDServiceRequest : EOperation


@property(nonatomic) SCDServiceResponseType responseType;


/*PROTECTED REGION ID(8b549d1d93dbdfb1051a4aae727bb82b) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
