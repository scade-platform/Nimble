#import <Foundation/Foundation.h>

#import <ScadeKit/SCDSvgAlignmentElement.h>
#import <ScadeKit/SCDSvgGroup.h>


@protocol SCDSvgAlignmentElement;

@class SCDSvgUnit;
@class SCDSvgGroup;


/*PROTECTED REGION ID(84a7dd5499b162f4f52ffad9df59f705) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDSvgPattern : SCDSvgGroup <SCDSvgAlignmentElement>


@property(nonatomic) SCDSvgUnit* _Nonnull width;

@property(nonatomic) SCDSvgUnit* _Nonnull height;

@property(nonatomic) SCDSvgUnit* _Nonnull x;

@property(nonatomic) SCDSvgUnit* _Nonnull y;

@property(nonatomic) NSString* _Nonnull viewBox;

@property(nonatomic, getter=isUserSpace) BOOL userSpace;

@property(nonatomic, getter=isContentUserSpace) BOOL contentUserSpace;


/*PROTECTED REGION ID(30ac5d9f90ba0184d4fe749c9c9ea507) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
