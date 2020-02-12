#import <Foundation/Foundation.h>

#import <ScadeKit/SCDLatticePoint.h>


@class SCDLatticeChanel;
@class SCDLatticePoint;


/*PROTECTED REGION ID(85dc560d2b1d923e42a97fcaff064bec) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDLatticeEntryPoint : SCDLatticePoint


@property(nonatomic) SCDLatticeChanel* _Nullable incoming;


- (void)back SWIFT_COMPILE_NAME("back()");

- (void)backWithData:(id _Nullable)data SWIFT_COMPILE_NAME("back(data:)");


/*PROTECTED REGION ID(9d46dcbcdcb65865e5995ff164e36899) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
