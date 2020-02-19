#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, SCDGraphicsHAlign) {
  SCDGraphicsHAlignLeft = 0,
  SCDGraphicsHAlignCenter = 1,
  SCDGraphicsHAlignRight = 2
};
typedef NS_ENUM(NSInteger, SCDGraphicsVAlign) {
  SCDGraphicsVAlignTop = 0,
  SCDGraphicsVAlignMiddle = 1,
  SCDGraphicsVAlignBottom = 2
};
typedef NS_ENUM(NSInteger, SCDGraphicsImageFormat) {
  SCDGraphicsImageFormatRgba32 = 0,
  SCDGraphicsImageFormatBgra32 = 1,
  SCDGraphicsImageFormatGrayscale8 = 2
};


#import <ScadeKit/SCDGraphicsPoint.h>

#import <ScadeKit/SCDGraphicsPointF.h>

#import <ScadeKit/SCDGraphicsDimension.h>

#import <ScadeKit/SCDGraphicsRectangle.h>

#import <ScadeKit/SCDGraphicsRGB.h>

#import <ScadeKit/SCDGraphicsImageData.h>

#import <ScadeKit/SCDGraphicsFont.h>
