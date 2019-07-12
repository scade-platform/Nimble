#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


/*PROTECTED REGION ID(bb061381b2044d803c35f8788299101e) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDSvgOnCompleteHandler : EObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;

- (instancetype _Nonnull)initWithHandler:(nonnull void (^)(BOOL))_
    NS_DESIGNATED_INITIALIZER;


- (void)invoke:(BOOL)arg;


/*PROTECTED REGION ID(2cedc5d1fc79ba2df55158d7ec35d464) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
