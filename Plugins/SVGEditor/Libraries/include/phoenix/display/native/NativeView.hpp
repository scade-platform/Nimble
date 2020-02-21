#ifndef PHOENIX_DISPLAY_NATIVE_NATIVIEW_HPP
#define PHOENIX_DISPLAY_NATIVE_NATIVIEW_HPP


#if defined(__APPLE__)

#include <TargetConditionals.h>

#ifdef __OBJC__

#if TARGET_OS_IPHONE
#import <UIKit/UIView.h>
typedef UIView NativeView;
#elif TARGET_OS_MAC
#import <AppKit/AppKit.h>
typedef NSView NativeView;
#endif // TARGET_OS_IPHONE

typedef NativeView* NativeView_ptr;

#else
typedef void* NativeView_ptr;
#endif //__OBJC__

#elif defined(__ANDROID__) || defined(__linux__)

typedef void* NativeView_ptr;

#endif // __Android__

#endif // PHOENIX_DISPLAY_NATIVE_NATIVIEW_HPP
