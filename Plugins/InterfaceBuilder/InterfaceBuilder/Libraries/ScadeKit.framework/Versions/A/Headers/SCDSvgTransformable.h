#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@protocol SCDSvgTransform;

@class SCDSvgMatrix;


/*PROTECTED REGION ID(0ecf6f0953358585b4fe0e89fa414a92) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@protocol SCDSvgTransformable <EObject>


@property(nonatomic) SCDSvgMatrix* _Nonnull matrix;

@property(nonatomic) id<SCDSvgTransform> _Nullable transform;


- (void)scale:(float)x y:(float)y;

- (void)translate:(float)x y:(float)y;

- (void)rotate:(float)angle;

- (void)rotateAround:(float)angle x:(float)x y:(float)y;


/*PROTECTED REGION ID(2b8368b1675f6fcfcae5067bde5ef520) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
