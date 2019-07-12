#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@class SCDWidgetsEditFinishEvent;


/*PROTECTED REGION ID(612bc50b8e703652e33608ef9fbc0730) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDWidgetsEditFinishEventHandler : EObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;

- (instancetype _Nonnull)initWithHandler:
    (nonnull void (^)(SCDWidgetsEditFinishEvent* _Nullable))_
    NS_DESIGNATED_INITIALIZER;


- (void)invoke:(SCDWidgetsEditFinishEvent* _Nullable)arg;


/*PROTECTED REGION ID(9b6b8649c5643cccf19fb2c869e10e69) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
