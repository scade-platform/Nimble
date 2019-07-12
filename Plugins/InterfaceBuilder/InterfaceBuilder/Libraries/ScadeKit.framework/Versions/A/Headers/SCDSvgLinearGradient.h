#import <Foundation/Foundation.h>

#import <ScadeKit/SCDSvgColor.h>
#import <ScadeKit/SCDSvgElement.h>


@protocol SCDSvgElement;

@class SCDSvgStop;
@class SCDSvgUnit;
@class SCDSvgColor;


/*PROTECTED REGION ID(b2fa5cd5766cd14949c766e06a9ee49b) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDSvgLinearGradient : SCDSvgColor <SCDSvgElement>

- (instancetype _Nonnull)init NS_UNAVAILABLE;

- (instancetype _Nonnull)initWithStops:(NSArray<SCDSvgStop*>* _Nonnull)stops
    NS_DESIGNATED_INITIALIZER;

@property(nonatomic, getter=isUserSpace) BOOL userSpace;

@property(nonatomic) NSArray<SCDSvgStop*>* _Nonnull stops;

@property(nonatomic) SCDSvgUnit* _Nonnull x1;

@property(nonatomic) SCDSvgUnit* _Nonnull y1;

@property(nonatomic) SCDSvgUnit* _Nonnull x2;

@property(nonatomic) SCDSvgUnit* _Nonnull y2;

@property(nonatomic) NSString* _Nonnull xhref;


/*PROTECTED REGION ID(4ef06ed67fc27825e60e0a2e5dd76067) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
