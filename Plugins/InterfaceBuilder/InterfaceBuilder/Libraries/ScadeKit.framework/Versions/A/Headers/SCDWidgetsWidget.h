#import <Foundation/Foundation.h>

#import <ScadeKit/SCDWidgetsIVisualControl.h>
#import <ScadeKit/SCDLayoutNode.h>


@protocol SCDWidgetsIContainer;
@protocol SCDWidgetsIVisualControl;
@protocol SCDLayoutNode;


/*PROTECTED REGION ID(979306310802c998d75e51203dad2ca6) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDWidgetsWidget : EObject <SCDWidgetsIVisualControl, SCDLayoutNode>


@property(nonatomic, readonly) id<SCDWidgetsIContainer> _Nullable parent;

@property(nonatomic, getter=isVisible) BOOL visible;

@property(nonatomic, getter=isEnable) BOOL enable;


- (BOOL)isPersistent;


/*PROTECTED REGION ID(bc2d2ec8ae3b8f3de3b26eb76e58fec3) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
