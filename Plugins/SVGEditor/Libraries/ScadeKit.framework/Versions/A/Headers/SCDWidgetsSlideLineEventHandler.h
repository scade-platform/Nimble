#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@class SCDWidgetsSlideLineEvent;


/*PROTECTED REGION ID(a9679b10bcfb172dc47bed1149fbe71e) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDWidgetsSlideLineEventHandler : EObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;

- (instancetype _Nonnull)initWithHandler:
    (nonnull void (^)(SCDWidgetsSlideLineEvent* _Nullable))_
    NS_DESIGNATED_INITIALIZER;


- (void)invoke:(SCDWidgetsSlideLineEvent* _Nullable)arg;


/*PROTECTED REGION ID(8e060b397ab0e6137eb6bdd81d9d3ff2) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
