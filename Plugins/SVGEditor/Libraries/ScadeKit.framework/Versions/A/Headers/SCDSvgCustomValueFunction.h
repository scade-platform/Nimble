#import <Foundation/Foundation.h>

#import <ScadeKit/SCDSvgValueFunction.h>


@protocol SCDSvgValueFunction;


/*PROTECTED REGION ID(ba2bc875d1c5dbe513f032528e4f052e) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDSvgCustomValueFunction : EObject <SCDSvgValueFunction>

- (instancetype _Nonnull)init NS_UNAVAILABLE;

- (instancetype _Nonnull)initWithHandler:(nonnull id _Nullable (^)(float))_
    NS_DESIGNATED_INITIALIZER;


- (id _Nullable)invoke:(float)arg;


/*PROTECTED REGION ID(5f8aa768dc0997b3a2bdcd04c6bde211) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
