#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@class SCDWidgetsSlideEvent;


/*PROTECTED REGION ID(f38ba122ae1614fa0e2103db5c797fd2) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDWidgetsSlideEventHandler : EObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;

- (instancetype _Nonnull)initWithHandler:
    (nonnull void (^)(SCDWidgetsSlideEvent* _Nullable))_
    NS_DESIGNATED_INITIALIZER;


- (void)invoke:(SCDWidgetsSlideEvent* _Nullable)arg;


/*PROTECTED REGION ID(5ed1de0770113ab239e5f997e6fec053) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
