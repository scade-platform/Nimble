#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@protocol SCDLayoutNode;


typedef NS_ENUM(NSInteger, SCDLayoutAnchor);


/*PROTECTED REGION ID(a9ec5ce72aa14ee1937222009228cf46) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDLayoutConstraint : EObject


@property(nonatomic) id<SCDLayoutNode> _Nullable source;

@property(nonatomic) SCDLayoutAnchor sourceAnchor;

@property(nonatomic) id<SCDLayoutNode> _Nullable target;

@property(nonatomic) SCDLayoutAnchor targetAnchor;

@property(nonatomic) float constant;

@property(nonatomic, getter=isActive) BOOL active;


/*PROTECTED REGION ID(ca4c3422a582ecd003fb71ee528ecd45) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
