#import <Foundation/Foundation.h>

#import <ScadeKit/SCDSvgShape.h>


@protocol SCDSvgShape;

@class SCDSvgPathElement;


/*PROTECTED REGION ID(7efc53e5684753b796ce55bd658882dd) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDSvgPath : EObject <SCDSvgShape>


@property(nonatomic) NSArray<SCDSvgPathElement*>* _Nonnull elements;


- (float)getLength;


/*PROTECTED REGION ID(8ae24bea757922a9a31bed3ab9694adb) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
