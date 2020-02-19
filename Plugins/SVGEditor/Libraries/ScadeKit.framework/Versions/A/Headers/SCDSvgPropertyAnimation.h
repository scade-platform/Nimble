#import <Foundation/Foundation.h>

#import <ScadeKit/SCDSvgBaseAnimation.h>


@protocol SCDSvgValueFunction;

@class SCDSvgBaseAnimation;


/*PROTECTED REGION ID(38990eee5e523255097fe15f56703fa7) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDSvgPropertyAnimation : SCDSvgBaseAnimation

- (instancetype _Nonnull)init NS_UNAVAILABLE;

- (instancetype _Nonnull)initWithKey:(NSString* _Nonnull)key
                       valueFunction:
                           (id<SCDSvgValueFunction> _Nonnull)valueFunction
    NS_DESIGNATED_INITIALIZER;

@property(nonatomic) NSString* _Nonnull key;

@property(nonatomic) id<SCDSvgValueFunction> _Nonnull valueFunction;


/*PROTECTED REGION ID(cf8b5eb95acee0780073aafac9c2ed25) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
