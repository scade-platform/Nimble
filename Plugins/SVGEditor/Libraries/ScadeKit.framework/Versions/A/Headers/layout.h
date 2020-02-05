#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, SCDLayoutLayoutSizeConstraint) {
  SCDLayoutLayoutSizeConstraintWrapContent = 0,
  SCDLayoutLayoutSizeConstraintMatchParent = 1
};
typedef NS_ENUM(NSInteger, SCDLayoutHorizontalAlignment) {
  SCDLayoutHorizontalAlignmentLeft = 0,
  SCDLayoutHorizontalAlignmentCenter = 1,
  SCDLayoutHorizontalAlignmentRight = 2
};
typedef NS_ENUM(NSInteger, SCDLayoutVerticalAlignment) {
  SCDLayoutVerticalAlignmentTop = 0,
  SCDLayoutVerticalAlignmentMiddle = 1,
  SCDLayoutVerticalAlignmentBottom = 2
};
typedef NS_ENUM(NSInteger, SCDLayoutAnchor) {
  SCDLayoutAnchorLeft = 0,
  SCDLayoutAnchorRight = 1,
  SCDLayoutAnchorTop = 2,
  SCDLayoutAnchorBottom = 3,
  SCDLayoutAnchorCenterX = 4,
  SCDLayoutAnchorCenterY = 5,
  SCDLayoutAnchorHeight = 6,
  SCDLayoutAnchorWidth = 7
};


#import <ScadeKit/SCDLayoutNode.h>

#import <ScadeKit/SCDLayoutILayoutable.h>

#import <ScadeKit/SCDLayoutLayout.h>

#import <ScadeKit/SCDLayoutLayoutData.h>

#import <ScadeKit/SCDLayoutGridData.h>

#import <ScadeKit/SCDLayoutGridLayout.h>

#import <ScadeKit/SCDLayoutStackLayout.h>

#import <ScadeKit/SCDLayoutGridStyle.h>

#import <ScadeKit/SCDLayoutAutoLayout.h>

#import <ScadeKit/SCDLayoutAutoLayoutData.h>

#import <ScadeKit/SCDLayoutConstraint.h>
