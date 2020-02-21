#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@class SCDGraphicsImageData;


/*PROTECTED REGION ID(24aa77fc9cb821a5292d7958e497b921) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDWidgetsVideoCaptureHandler : EObject

- (instancetype _Nonnull)init NS_UNAVAILABLE;

- (instancetype _Nonnull)initWithHandler:
    (nonnull void (^)(SCDGraphicsImageData* _Nullable))_
    NS_DESIGNATED_INITIALIZER;


- (void)invoke:(SCDGraphicsImageData* _Nullable)arg;


/*PROTECTED REGION ID(dcd75bcb16fabc11f749139f9ba23724) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
