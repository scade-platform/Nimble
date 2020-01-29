#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@class SCDLatticeExitPoint;
@class SCDLatticeEntryPoint;


/*PROTECTED REGION ID(7f91118f26551306a8a53221fce242d9) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDLatticeChanel : EObject


@property(nonatomic) SCDLatticeExitPoint* _Nullable src;

@property(nonatomic) SCDLatticeEntryPoint* _Nullable dst;

@property(nonatomic) NSString* _Nonnull name;


/*PROTECTED REGION ID(4a3783d1fd64921db30f95254da9299f) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
