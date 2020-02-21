#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@class EObject;
@class SCDBindingBindingSyncPoint;


/*PROTECTED REGION ID(8687be7fdcacf71888849d0bcb0e9490) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDBindingBinding : EObject


@property(nonatomic) EObject* _Nullable src;

@property(nonatomic) EObject* _Nullable dst;

@property(nonatomic) SCDBindingBindingSyncPoint* _Nullable root;

@property(nonatomic, getter=isActive) BOOL active;


- (void)activate;

- (void)deactivate;


/*PROTECTED REGION ID(6f71dd8988dfd2547cf908017e5b3610) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
