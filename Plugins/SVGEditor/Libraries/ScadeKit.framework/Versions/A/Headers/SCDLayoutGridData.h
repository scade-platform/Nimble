#import <Foundation/Foundation.h>

#import <ScadeKit/SCDLayoutLayoutData.h>


@class SCDGraphicsDimension;
@class SCDLayoutGridStyle;
@class SCDLayoutLayoutData;

typedef NS_ENUM(NSInteger, SCDLayoutHorizontalAlignment);
typedef NS_ENUM(NSInteger, SCDLayoutVerticalAlignment);
typedef NS_ENUM(NSInteger, SCDLayoutLayoutSizeConstraint);


/*PROTECTED REGION ID(53ccb8767cf6ba1abe508274fe8c9aa1) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDLayoutGridData : SCDLayoutLayoutData


@property(nonatomic) SCDGraphicsDimension* _Nonnull minSize;

@property(nonatomic) SCDGraphicsDimension* _Nonnull maxSize;

@property(nonatomic) long column;

@property(nonatomic) long row;

@property(nonatomic) SCDLayoutHorizontalAlignment horizontalAlignment;

@property(nonatomic) SCDLayoutVerticalAlignment verticalAlignment;

@property(nonatomic, getter=isGrabHorizontalSpace) BOOL grabHorizontalSpace;

@property(nonatomic, getter=isGrabVerticalSpace) BOOL grabVerticalSpace;

@property(nonatomic) SCDLayoutLayoutSizeConstraint widthConstraint;

@property(nonatomic) SCDLayoutLayoutSizeConstraint heightConstraint;

@property(nonatomic) long horizontalIndent;

@property(nonatomic) long verticalIndent;

@property(nonatomic) long horizontalSpan;

@property(nonatomic) long verticalSpan;

@property(nonatomic, getter=isExclude) BOOL exclude;

@property(nonatomic) SCDLayoutGridStyle* _Nonnull gridStyle;


/*PROTECTED REGION ID(99a6cabd1f38d939d18afb02f1f1e65d) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
