#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


/*PROTECTED REGION ID(c97aac3c3471451e68a701dd1417bee3) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDNetworkResponse : EObject


@property(nonatomic) NSData* _Nonnull body;

@property(nonatomic) NSDictionary<NSString*, NSString*>* _Nonnull headers;

@property(nonatomic) long statusCode;

@property(nonatomic) NSString* _Nonnull statusMessage;


- (BOOL)isOk;


/*PROTECTED REGION ID(c9f6d65fe7bf30b22d983f8c065029d5) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
