#import <Foundation/Foundation.h>

#import <ScadeKit/SCDLayoutNode.h>
#import <ScadeKit/SCDSvgAlignmentElement.h>
#import <ScadeKit/SCDSvgGroup.h>


@protocol SCDSvgAlignmentElement;
@protocol SCDLayoutNode;

@class SCDSvgUnit;
@class SCDSvgGroup;


/*PROTECTED REGION ID(0ae0de62c6f9adf228ed93d1d643c2d6) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDSvgBox : SCDSvgGroup <SCDSvgAlignmentElement, SCDLayoutNode>


@property(nonatomic) NSString* _Nonnull viewBox;

@property(nonatomic) SCDSvgUnit* _Nonnull x;

@property(nonatomic) SCDSvgUnit* _Nonnull y;

@property(nonatomic) SCDSvgUnit* _Nonnull width;

@property(nonatomic) SCDSvgUnit* _Nonnull height;


/*PROTECTED REGION ID(5a636e962e0a47769ed076bd6ebed9f6) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
