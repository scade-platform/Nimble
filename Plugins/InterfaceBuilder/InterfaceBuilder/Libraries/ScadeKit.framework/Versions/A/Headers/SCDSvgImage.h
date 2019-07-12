#import <Foundation/Foundation.h>

#import <ScadeKit/SCDSvgDrawable.h>
#import <ScadeKit/SCDSvgAlignmentElement.h>


@protocol SCDSvgDrawable;
@protocol SCDSvgAlignmentElement;

@class SCDSvgUnit;
@class SCDGraphicsImageData;


/*PROTECTED REGION ID(99078392805aa58a22d272ef44b9a550) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDSvgImage : EObject <SCDSvgDrawable, SCDSvgAlignmentElement>


@property(nonatomic) NSString* _Nonnull xhref;

@property(nonatomic) SCDSvgUnit* _Nonnull x;

@property(nonatomic) SCDSvgUnit* _Nonnull y;

@property(nonatomic) SCDSvgUnit* _Nonnull width;

@property(nonatomic) SCDSvgUnit* _Nonnull height;

@property(nonatomic) NSString* _Nonnull content;

@property(nonatomic) SCDGraphicsImageData* _Nullable imageData;


/*PROTECTED REGION ID(045fdb0387015fb098cf407e07836f83) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
