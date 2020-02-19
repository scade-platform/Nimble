#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@class SCDGraphicsRGB;


/*PROTECTED REGION ID(dc63472f883ac61834e53c3298737507) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDGraphicsFont : EObject


@property(nonatomic) NSString* _Nonnull fontFamily;

@property(nonatomic) long size;

@property(nonatomic, getter=isBold) BOOL bold;

@property(nonatomic, getter=isItalic) BOOL italic;

@property(nonatomic, getter=isLineThrough) BOOL lineThrough;

@property(nonatomic, getter=isUnderline) BOOL underline;

@property(nonatomic) SCDGraphicsRGB* _Nonnull color;


/*PROTECTED REGION ID(9eac97acf6a8a22cd2262176448bf007) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
