#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, SCDSvgAspectRatio) {
  SCDSvgAspectRatioMeet = 0,
  SCDSvgAspectRatioSlice = 1,
  SCDSvgAspectRatioNone = 2
};
typedef NS_ENUM(NSInteger, SCDSvgTextAnchor) {
  SCDSvgTextAnchorStart = 0,
  SCDSvgTextAnchorMiddle = 1,
  SCDSvgTextAnchorEnd = 2
};
typedef NS_ENUM(NSInteger, SCDSvgMeasurement) {
  SCDSvgMeasurementPixel = 0,
  SCDSvgMeasurementPercentage = 1
};
typedef NS_ENUM(NSInteger, SCDSvgBoxAlignment) {
  SCDSvgBoxAlignmentXmidymid = 0,
  SCDSvgBoxAlignmentXminymin = 1,
  SCDSvgBoxAlignmentXminymid = 2,
  SCDSvgBoxAlignmentXminymax = 3,
  SCDSvgBoxAlignmentXmidymin = 4,
  SCDSvgBoxAlignmentXmidymax = 5,
  SCDSvgBoxAlignmentXmaxymin = 6,
  SCDSvgBoxAlignmentXmaxymid = 7,
  SCDSvgBoxAlignmentXmaxymax = 8
};
typedef NS_ENUM(NSInteger, SCDSvgTextAlignmentBaseline) {
  SCDSvgTextAlignmentBaselineAlphabetic = 0,
  SCDSvgTextAlignmentBaselineHanging = 1,
  SCDSvgTextAlignmentBaselineCentral = 2
};
typedef NS_ENUM(NSInteger, SCDSvgScrollType) {
  SCDSvgScrollTypeVertical = 0,
  SCDSvgScrollTypeHorizontal = 1,
  SCDSvgScrollTypeAll = 2
};
typedef NS_ENUM(NSInteger, SCDSvgTextAlignment) {
  SCDSvgTextAlignmentLeft = 0,
  SCDSvgTextAlignmentCenter = 1,
  SCDSvgTextAlignmentRight = 2
};


typedef NS_ENUM(NSInteger, SCDSvgLineJoin) {
  SCDSvgLineJoinMitter = 0,
  SCDSvgLineJoinRound = 1,
  SCDSvgLineJoinBevel = 2
};
typedef NS_ENUM(NSInteger, SCDSvgFillRule) {
  SCDSvgFillRuleNonzero = 0,
  SCDSvgFillRuleEvenodd = 1
};
typedef NS_ENUM(NSInteger, SCDSvgFontStyle) {
  SCDSvgFontStyleInherit = 0,
  SCDSvgFontStyleNormal = 1,
  SCDSvgFontStyleItalic = 2
};
typedef NS_ENUM(NSInteger, SCDSvgTextDecoration) {
  SCDSvgTextDecorationInherit = 0,
  SCDSvgTextDecorationNone = 1,
  SCDSvgTextDecorationUnderline = 2,
  SCDSvgTextDecorationThrough = 3,
  SCDSvgTextDecorationUnderlinethrough = 4
};


typedef NS_ENUM(NSInteger, SCDSvgTouchEventPhase) {
  SCDSvgTouchEventPhaseBegan = 0,
  SCDSvgTouchEventPhaseMoved = 1,
  SCDSvgTouchEventPhaseEnded = 2,
  SCDSvgTouchEventPhaseCancelled = 3
};
typedef NS_ENUM(NSInteger, SCDSvgTouchHandlerState) {
  SCDSvgTouchHandlerStatePossible = 0,
  SCDSvgTouchHandlerStateBegan = 1,
  SCDSvgTouchHandlerStateChanged = 2,
  SCDSvgTouchHandlerStateEnded = 3,
  SCDSvgTouchHandlerStateFailed = 4
};

typedef NS_ENUM(NSInteger, SCDSvgSwipeDirection) {
  SCDSvgSwipeDirectionLeft = 1,
  SCDSvgSwipeDirectionRight = 2,
  SCDSvgSwipeDirectionUp = 3,
  SCDSvgSwipeDirectionDown = 4
};

typedef NS_ENUM(NSInteger, SCDSvgFillMode) {
  SCDSvgFillModeRemove = 0,
  SCDSvgFillModeFreeze = 1
};


#import <ScadeKit/SCDSvgElement.h>

#import <ScadeKit/SCDSvgContainerElement.h>


#import <ScadeKit/SCDSvgAlignmentElement.h>

#import <ScadeKit/SCDSvgDrawable.h>

#import <ScadeKit/SCDSvgBox.h>

#import <ScadeKit/SCDSvgGroup.h>

#import <ScadeKit/SCDSvgShape.h>

#import <ScadeKit/SCDSvgPath.h>

#import <ScadeKit/SCDSvgLine.h>

#import <ScadeKit/SCDSvgRect.h>

#import <ScadeKit/SCDSvgCircle.h>

#import <ScadeKit/SCDSvgEllipse.h>

#import <ScadeKit/SCDSvgPolyline.h>

#import <ScadeKit/SCDSvgTextSegment.h>

#import <ScadeKit/SCDSvgTextElement.h>

#import <ScadeKit/SCDSvgTextSpan.h>

#import <ScadeKit/SCDSvgText.h>

#import <ScadeKit/SCDSvgUse.h>

#import <ScadeKit/SCDSvgImage.h>

#import <ScadeKit/SCDSvgSymbol.h>

#import <ScadeKit/SCDSvgPattern.h>

#import <ScadeKit/SCDSvgScrollGroup.h>

#import <ScadeKit/SCDSvgClipPath.h>


#import <ScadeKit/SCDSvgUnit.h>


#import <ScadeKit/SCDSvgPathElement.h>

#import <ScadeKit/SCDSvgPathMove.h>

#import <ScadeKit/SCDSvgPathLine.h>

#import <ScadeKit/SCDSvgPathHLine.h>

#import <ScadeKit/SCDSvgPathVLine.h>

#import <ScadeKit/SCDSvgPathCubic.h>

#import <ScadeKit/SCDSvgPathSCubic.h>

#import <ScadeKit/SCDSvgPathQuadratic.h>

#import <ScadeKit/SCDSvgPathSQuadratic.h>

#import <ScadeKit/SCDSvgPathElliptical.h>

#import <ScadeKit/SCDSvgPathClose.h>


#import <ScadeKit/SCDSvgStylable.h>

#import <ScadeKit/SCDSvgFontStyleable.h>


#import <ScadeKit/SCDSvgColor.h>

#import <ScadeKit/SCDSvgRGBColor.h>

#import <ScadeKit/SCDSvgNoneColor.h>

#import <ScadeKit/SCDSvgLinearGradient.h>

#import <ScadeKit/SCDSvgStop.h>


#import <ScadeKit/SCDSvgTransformable.h>

#import <ScadeKit/SCDSvgMatrix.h>

#import <ScadeKit/SCDSvgTransform.h>

#import <ScadeKit/SCDSvgScale.h>

#import <ScadeKit/SCDSvgTranslate.h>

#import <ScadeKit/SCDSvgRotate.h>

#import <ScadeKit/SCDSvgSkewX.h>

#import <ScadeKit/SCDSvgSkewY.h>

#import <ScadeKit/SCDSvgMatrixTransform.h>


#import <ScadeKit/SCDSvgSvgResource.h>


#import <ScadeKit/SCDSvgTouchEvent.h>

#import <ScadeKit/SCDSvgTouchHandler.h>

#import <ScadeKit/SCDSvgTouchReceiver.h>

#import <ScadeKit/SCDSvgScrollEvent.h>

#import <ScadeKit/SCDSvgScrollHandler.h>

#import <ScadeKit/SCDSvgDrawableHandler.h>


#import <ScadeKit/SCDSvgGestureRecognizer.h>

#import <ScadeKit/SCDSvgTouchGestureRecognizer.h>

#import <ScadeKit/SCDSvgSwipeGestureRecognizer.h>

#import <ScadeKit/SCDSvgTapGestureRecognizer.h>

#import <ScadeKit/SCDSvgPanGestureRecognizer.h>


#import <ScadeKit/SCDSvgValueFunction.h>

#import <ScadeKit/SCDSvgCustomValueFunction.h>

#import <ScadeKit/SCDSvgValueInterpolator.h>

#import <ScadeKit/SCDSvgTimeFunction.h>

#import <ScadeKit/SCDSvgCustomTimeFunction.h>

#import <ScadeKit/SCDSvgCubicTimeFunction.h>

#import <ScadeKit/SCDSvgSplineTimeFunction.h>

#import <ScadeKit/SCDSvgAnimatable.h>

#import <ScadeKit/SCDSvgAnimation.h>

#import <ScadeKit/SCDSvgGroupAnimation.h>

#import <ScadeKit/SCDSvgBaseAnimation.h>

#import <ScadeKit/SCDSvgPropertyAnimation.h>

#import <ScadeKit/SCDSvgTranslateAnimation.h>

#import <ScadeKit/SCDSvgRotateAnimation.h>

#import <ScadeKit/SCDSvgMotionAnimation.h>

#import <ScadeKit/SCDSvgOnCompleteHandler.h>


#import <ScadeKit/SCDSvgConstraint.h>

#import <ScadeKit/SCDSvgMatrixConstraint.h>

#import <ScadeKit/SCDSvgDirectConstraint.h>

#import <ScadeKit/SCDSvgScrollSizeConstraint.h>

#import <ScadeKit/SCDSvgViewBoxConstraint.h>


#import <ScadeKit/SCDSvgAccessibility.h>
