#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@class SCDWidgetsWidget;


/*PROTECTED REGION ID(4d8fa5c791a43c18b3dd1797ba374cc8) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDWidgetsListElementProvider : EObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;

- (instancetype _Nonnull)initWithHandler:
    (nonnull SCDWidgetsWidget* _Nullable (^)(long))_ NS_DESIGNATED_INITIALIZER;


- (SCDWidgetsWidget* _Nullable)invoke:(long)arg;


/*PROTECTED REGION ID(4f74a783176b55c4cf376e1b466a9fa5) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
