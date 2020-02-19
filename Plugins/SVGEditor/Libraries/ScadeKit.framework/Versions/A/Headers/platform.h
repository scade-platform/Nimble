#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, SCDPlatformCameraSourceType) {
  SCDPlatformCameraSourceTypeCamera = 0,
  SCDPlatformCameraSourceTypePhotolibrary = 1
};

typedef NS_ENUM(NSInteger, SCDPlatformContactPhoneLabelKey) {
  SCDPlatformContactPhoneLabelKeyMain = 0,
  SCDPlatformContactPhoneLabelKeyMobile = 1,
  SCDPlatformContactPhoneLabelKeyPager = 2,
  SCDPlatformContactPhoneLabelKeyHomefax = 3,
  SCDPlatformContactPhoneLabelKeyWorkfax = 4,
  SCDPlatformContactPhoneLabelKeyOtherfax = 5,
  SCDPlatformContactPhoneLabelKeyOther = 6
};
typedef NS_ENUM(NSInteger, SCDPlatformContactLabelKey) {
  SCDPlatformContactLabelKeyHome = 0,
  SCDPlatformContactLabelKeyWork = 1,
  SCDPlatformContactLabelKeyOther = 2
};
typedef NS_ENUM(NSInteger, SCDPlatformContactIMLabelKey) {
  SCDPlatformContactIMLabelKeyAim = 0,
  SCDPlatformContactIMLabelKeyGoogletalk = 1,
  SCDPlatformContactIMLabelKeyIcq = 2,
  SCDPlatformContactIMLabelKeyJabber = 3,
  SCDPlatformContactIMLabelKeyMsn = 4,
  SCDPlatformContactIMLabelKeyQq = 5,
  SCDPlatformContactIMLabelKeySkype = 6,
  SCDPlatformContactIMLabelKeyYahoo = 7,
  SCDPlatformContactIMLabelKeyOther = 8
};


#import <ScadeKit/SCDPlatformCamera.h>

#import <ScadeKit/SCDPlatformCameraSuccessHandler.h>

#import <ScadeKit/SCDPlatformCameraErrorHandler.h>

#import <ScadeKit/SCDPlatformCameraOptions.h>


#import <ScadeKit/SCDPlatformContacts.h>

#import <ScadeKit/SCDPlatformContact.h>

#import <ScadeKit/SCDPlatformContactAddress.h>

#import <ScadeKit/SCDPlatformContactSearchResult.h>

#import <ScadeKit/SCDPlatformContactPhone.h>

#import <ScadeKit/SCDPlatformContactLabel.h>

#import <ScadeKit/SCDPlatformContactEmail.h>

#import <ScadeKit/SCDPlatformContactUrl.h>

#import <ScadeKit/SCDPlatformContactIM.h>


#import <ScadeKit/SCDPlatformLocationCoordinate.h>
