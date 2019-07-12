#import <Foundation/Foundation.h>

#import <ScadeKit/SCDWidgetsNativeWidget.h>


@class SCDWidgetsMapRegion;
@class SCDPlatformLocationCoordinate;
@class SCDWidgetsMapOverlay;
@class SCDWidgetsMapAnnotation;
@class SCDWidgetsNativeWidget;
@class SCDGraphicsPointF;

typedef NS_ENUM(NSInteger, SCDWidgetsMapType);


/*PROTECTED REGION ID(318730a9070ff72b8414d33b95718d65) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDWidgetsMapWidget : SCDWidgetsNativeWidget


@property(nonatomic) SCDWidgetsMapType mapType;

@property(nonatomic, readonly) SCDWidgetsMapRegion* _Nonnull currentRegion;

@property(nonatomic, readonly)
    SCDPlatformLocationCoordinate* _Nonnull userLocation;

@property(nonatomic, getter=isShowUserLocation) BOOL showUserLocation;

@property(nonatomic) NSArray<SCDWidgetsMapOverlay*>* _Nonnull overlays;

@property(nonatomic) NSArray<SCDWidgetsMapAnnotation*>* _Nonnull annotations;


- (void)setRegion:(SCDPlatformLocationCoordinate* _Nonnull)center
     latitudinalMeters:(double)latitudinalMeters
    longitudinalMeters:(double)longitudinalMeters;

- (void)moveToUserLocation;

- (SCDPlatformLocationCoordinate* _Nonnull)convertToGeoLocation:
    (SCDGraphicsPointF* _Nonnull)point;

- (SCDGraphicsPointF* _Nonnull)convertFromGeoLocation:
    (SCDPlatformLocationCoordinate* _Nonnull)location;

- (float)convertDistanceToMapPointsAt:(double)latitude distance:(float)distance;


/*PROTECTED REGION ID(b6e3f2e7be254d3497392116c070f8b7) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
