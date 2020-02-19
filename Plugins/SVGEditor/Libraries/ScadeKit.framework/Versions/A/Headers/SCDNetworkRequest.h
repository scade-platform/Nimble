#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@class SCDNetworkContentPart;
@class SCDNetworkByteContentPart;
@class SCDNetworkAuth;
@class SCDNetworkErrorHandler;
@class SCDNetworkResponse;
@class SCDNetworkAsyncCallback;

typedef NS_ENUM(NSInteger, SCDNetworkMethod);


/*PROTECTED REGION ID(686d8702b165e92f94502ad792115d6b) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDNetworkRequest : EObject


@property(nonatomic) SCDNetworkMethod method;

@property(nonatomic) NSString* _Nonnull url;

@property(nonatomic) NSDictionary<NSString*, NSString*>* _Nonnull params;

@property(nonatomic) NSDictionary<NSString*, NSString*>* _Nonnull headers;

@property(nonatomic) NSArray<SCDNetworkContentPart*>* _Nonnull contents;

@property(nonatomic) NSArray<SCDNetworkByteContentPart*>* _Nonnull byteContents;

@property(nonatomic) SCDNetworkAuth* _Nullable auth;

@property(nonatomic) SCDNetworkErrorHandler* _Nullable onError;

@property(nonatomic) long timeout;


- (void)addContent:(NSString* _Nonnull)content type:(NSString* _Nonnull)type;

- (void)addJsonContent:(NSString* _Nonnull)content;

- (void)addXmlContent:(NSString* _Nonnull)content;

- (void)addTextContent:(NSString* _Nonnull)content;

- (void)addFormContent:(NSString* _Nonnull)content;

- (void)addByteContent:(NSData* _Nonnull)content type:(NSString* _Nonnull)type;

- (SCDNetworkResponse* _Nullable)call;

- (void)asyncCall:(SCDNetworkAsyncCallback* _Nullable)callback;

- (void)addHeader:(NSString* _Nonnull)name value:(NSString* _Nonnull)value;

- (void)removeHeader:(NSString* _Nonnull)name;


/*PROTECTED REGION ID(825e1f55cbcd78a4954f6b39a726bd51) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
