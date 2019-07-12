#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@class SCDSvgScrollEvent;


/*PROTECTED REGION ID(5626131b94c9e0fcbc55d9baab8bfd21) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDSvgScrollHandler : EObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;

- (instancetype _Nonnull)initWithHandler:
    (nonnull void (^)(SCDSvgScrollEvent* _Nullable))_ NS_DESIGNATED_INITIALIZER;


- (void)invoke:(SCDSvgScrollEvent* _Nullable)arg;


/*PROTECTED REGION ID(6c5924fd7d8548c92e1cb73da4a3af7a) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
