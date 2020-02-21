#import <Foundation/Foundation.h>

#import <ScadeKit/SCDSvgGroup.h>


@class SCDSvgScrollHandler;
@class SCDSvgGroup;
@class SCDGraphicsDimension;
@class SCDGraphicsPoint;

typedef NS_ENUM(NSInteger, SCDSvgScrollType);


/*PROTECTED REGION ID(d1b9c6a0d4736b52defbf827f06ed43e) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDSvgScrollGroup : SCDSvgGroup


@property(nonatomic) long width;

@property(nonatomic) long height;

@property(nonatomic) SCDSvgScrollType type;

@property(nonatomic) NSArray<SCDSvgScrollHandler*>* _Nonnull onScroll;


- (SCDGraphicsDimension* _Nonnull)getContentSize;

- (SCDGraphicsPoint* _Nonnull)getPosition;

- (void)scrollTo:(long)x y:(long)y;

- (void)setScrollBarEnabled:(BOOL)flag;


/*PROTECTED REGION ID(afc16493809f6fdeb27785e67e9cc1b8) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
