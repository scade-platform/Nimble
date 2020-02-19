#import <Foundation/Foundation.h>

#import <ScadeKit/SCDWidgetsWidget.h>


@class SCDWidgetsWidget;

typedef NS_ENUM(NSInteger, SCDWidgetsDataWheelAlignment);


/*PROTECTED REGION ID(bc6dfc2567048401620d01c4af5508d1) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDWidgetsDataWheel : SCDWidgetsWidget


@property(nonatomic) NSArray<NSString*>* _Nonnull data;

@property(nonatomic) long width;

@property(nonatomic) SCDWidgetsDataWheelAlignment alignment;

@property(nonatomic, getter=isCycle) BOOL cycle;

@property(nonatomic) NSString* _Nonnull selected;


- (long)textLocation;


/*PROTECTED REGION ID(1a342c0e10ee8bbfd7a5214688d52396) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
