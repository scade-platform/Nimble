#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@class SCDSvgConstraint;


/*PROTECTED REGION ID(e512a6874ca44e6a8504ea1cbeaddcff) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@protocol SCDSvgElement <EObject>


@property(nonatomic) NSString* _Nonnull id;

@property(nonatomic) NSDictionary<NSString*, NSString*>* _Nonnull attributes;

@property(nonatomic) NSArray<SCDSvgConstraint*>* _Nonnull constraints;


- (id<SCDSvgElement> _Nullable)findById:(NSString* _Nonnull)id;


/*PROTECTED REGION ID(72d0ac65831f5386d7e0dfbc54d177a7) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
