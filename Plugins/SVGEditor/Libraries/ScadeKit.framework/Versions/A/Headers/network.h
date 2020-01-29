#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, SCDNetworkMethod) {
  SCDNetworkMethodGet = 0,
  SCDNetworkMethodPost = 1,
  SCDNetworkMethodPut = 2,
  SCDNetworkMethodDelete = 3,
  SCDNetworkMethodHeader = 4
};


#import <ScadeKit/SCDNetworkAuth.h>

#import <ScadeKit/SCDNetworkBasicAuth.h>


#import <ScadeKit/SCDNetworkRequest.h>

#import <ScadeKit/SCDNetworkContentPart.h>

#import <ScadeKit/SCDNetworkByteContentPart.h>

#import <ScadeKit/SCDNetworkErrorHandler.h>

#import <ScadeKit/SCDNetworkResponse.h>

#import <ScadeKit/SCDNetworkAsyncCallback.h>

#import <ScadeKit/SCDNetworkResponseError.h>
