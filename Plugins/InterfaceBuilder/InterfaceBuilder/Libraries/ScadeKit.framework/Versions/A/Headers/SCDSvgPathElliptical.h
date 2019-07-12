#import <Foundation/Foundation.h>

#import <ScadeKit/SCDSvgPathElement.h>


@class SCDSvgPathElement;


/*PROTECTED REGION ID(0e8b73f0016a79df321775242a8c362d) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDSvgPathElliptical : SCDSvgPathElement


@property(nonatomic) float rx;

@property(nonatomic) float ry;

@property(nonatomic) float angle;

@property(nonatomic, getter=isLargeArc) BOOL largeArc;

@property(nonatomic, getter=isSweep) BOOL sweep;

@property(nonatomic) float x;

@property(nonatomic) float y;


/*PROTECTED REGION ID(a8ee8c34ecfcc7f751234682e8cc1135) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
