#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@protocol SCDSvgDrawable;


/*PROTECTED REGION ID(b27f0d3a0269d321d80e43188807605d) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDSvgDrawableHandler : EObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;

- (instancetype _Nonnull)initWithHandler:
    (nonnull void (^)(id<SCDSvgDrawable> _Nullable))_ NS_DESIGNATED_INITIALIZER;


- (void)invoke:(id<SCDSvgDrawable> _Nullable)arg;


/*PROTECTED REGION ID(31dd92bf0eef517094415527d504fd4a) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
