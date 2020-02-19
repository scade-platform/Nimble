#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@class SCDLatticeSizeChangedEvent;


/*PROTECTED REGION ID(002dcb72ea2b63f3f4d1723687dd4710) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDLatticeSizeChangeHandler : EObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;

- (instancetype _Nonnull)initWithHandler:
    (nonnull void (^)(SCDLatticeSizeChangedEvent* _Nonnull))_
    NS_DESIGNATED_INITIALIZER;


- (void)invoke:(SCDLatticeSizeChangedEvent* _Nonnull)arg;


/*PROTECTED REGION ID(066ecb6cb3867b4b10bc1dcd5afc97d1) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
