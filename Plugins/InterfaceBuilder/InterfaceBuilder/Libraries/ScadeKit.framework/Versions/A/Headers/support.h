//
//  runtime.h
//  ScadeSDK
//
//  Created by Grigory Markin on 02/02/16.
//  Copyright © 2016 Scade. All rights reserved.
//
#import <ScadeKit/ScadeKit-Defs.h>
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <ScadeKit/SCDNotification.h>
#import <ScadeKit/SCDObserver.h>


@class EObject;
@class EPackage;
@class EClass;
@class EStructuralFeature;
@class SCDLatticeSystem;


SCADE_API
@interface SCDApplication : NSObject

- (void)onEnterBackground;

- (void)onEnterForeground;

- (void)onFinishLaunching;

- (void)onOpenWith:(NSString* _Nonnull)url;

- (void)launch;

@end


SCADE_API
@interface SCDRuntime : NSObject

+ (void)initRuntime:(SCDApplication* _Nonnull)app;

+ (EPackage* _Nullable)loadMetaModel:(NSString* _Nonnull)relativePath;

+ (EObject* _Nullable)loadResource:(NSString* _Nonnull)relativePath;

+ (EObject* _Nullable)loadTemplate:(NSString* _Nonnull)name;

+ (EObject* _Nullable)loadDocument:(NSString* _Nonnull)relativePath;

+ (void)saveDocument:(NSString* _Nonnull)relativePath
            document:(EObject* _Nonnull)eObject;

+ (void)saveFile:(NSString* _Nonnull)relativePath
         content:(NSString* _Nonnull)data;

+ (void)saveFile:(NSString* _Nonnull)relativePath data:(NSData* _Nonnull)data;

+ (NSData* _Nullable)loadFile:(NSString* _Nonnull)relativePath;

+ (void)callWithDelay:(double)seconds closure:(void (^_Nonnull)())block;

+ (SCDLatticeSystem* _Nonnull)getSystem;

//#if DEBUG
+ (EObject* _Nullable)parseSvg:(NSString* _Nonnull)relativePath;

+ (EObject* _Nullable)parseSvgContent:(NSString* _Nonnull)content;

//+(void) renderSvg:(EObject*)object rect:(CGRect) rectangle;
+ (void)renderSvg:(EObject* _Nonnull)object
                x:(double)xValue
                y:(double)yValue
             size:(CGSize)sizeValue;
//#endif //DEBUG

+ (EClass* _Nonnull)getEClassFor:(Class _Nonnull)cls;

+ (EObject* _Nonnull)clone:(EObject* _Nonnull)object;

+ (void)loadMetaModel;

+ (EObject* _Nullable)loadXmiResource:(NSString* _Nonnull)relativePath;
@end


SCADE_API
@interface SCDDisplay : NSObject

+ (CGSize)getSize;

+ (void)frameChanged:(CGSize)size;

@end


// TODO: Notifcation API
/*
typedef NS_ENUM(NSInteger, SCDNotificationType) {
  SCD_NOTIFICATION_CREATE, // deprecated
  SCD_NOTIFICATION_SET,
  SCD_NOTIFICATION_UNSET,
  SCD_NOTIFICATION_ADD,
  SCD_NOTIFICATION_REMOVE,
  SCD_NOTIFICATION_ADD_MANY,
  SCD_NOTIFICATION_REMOVE_MANY,
  SCD_NOTIFICATION_MOVE,
  SCD_NOTIFICATION_REMOVING_ADAPTER,
  SCD_NOTIFICATION_RESOLVE,
  SCD_NOTIFICATION_EVENT_TYPE_COUNT,
  SCD_NOTIFICATION_UNKNOWN
};


SCADE_API
@interface SCDNotification : NSObject

- (instancetype)init NS_UNAVAILABLE;

@property(nonatomic, readonly) EObject* notifier;

@property(nonatomic, readonly) EStructuralFeature* feature;

@property(nonatomic, readonly) SCDNotificationType type;

@property(nonatomic, readonly) id value;

@property(nonatomic, readonly) id oldValue;

@property(nonatomic, readonly) NSUInteger position;

@property(nonatomic, readonly) id key;

@end


SCADE_API
@interface SCDNotificationAdapter : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithHandler:(void (^)(SCDNotification*))_;
@end

*/
