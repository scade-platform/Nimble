#import <Foundation/Foundation.h>

#import <ScadeKit/SCDSvgTimeFunction.h>


@class SCDSvgTimeFunction;


/*PROTECTED REGION ID(435cdeaa572d8e513f401533da89885f) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDSvgCustomTimeFunction : SCDSvgTimeFunction

- (instancetype _Nonnull)init NS_UNAVAILABLE;

- (instancetype _Nonnull)initWithHandler:(nonnull float (^)(float))_
    NS_DESIGNATED_INITIALIZER;


- (float)invoke:(float)arg;


/*PROTECTED REGION ID(bae88c9e5cc51b9d667b765da3cd564a) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
