#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@class SCDWidgetsDatePickerEvent;


/*PROTECTED REGION ID(b534f004b1c24c9a2d2c12865e2da8fb) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDWidgetsDatePickerEventHandler : EObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;

- (instancetype _Nonnull)initWithHandler:
    (nonnull void (^)(SCDWidgetsDatePickerEvent* _Nullable))_
    NS_DESIGNATED_INITIALIZER;


- (void)invoke:(SCDWidgetsDatePickerEvent* _Nullable)arg;


/*PROTECTED REGION ID(776a60a7084e9e94f5878c9a1ab2fc19) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
