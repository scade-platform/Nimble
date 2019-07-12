#import <Foundation/Foundation.h>

#import <ScadeKit/SCDServiceRequest.h>


@class SCDServiceRequest;
@class SCDNetworkRequest;

typedef NS_ENUM(NSInteger, SCDServiceHttpMethod);


/*PROTECTED REGION ID(46985fc88014b83f20356af282afc45c) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDServiceHttpRequest : SCDServiceRequest


@property(nonatomic) SCDServiceHttpMethod method;

@property(nonatomic) NSString* _Nonnull url;

@property(nonatomic) long timeout;


- (SCDNetworkRequest* _Nullable)getRequest:(NSArray<id>* _Nonnull)args;


/*PROTECTED REGION ID(9289ca3d855a205f2464786f4de112a7) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
