//
//  ScadeKit.h
//  ScadeKit
//
//  Created by Grigory Markin on 21/02/16.
//  Copyright © 2016 Scade. All rights reserved.
//

#import <Foundation/Foundation.h>

#if defined(__linux__)

#import <ecore.h>
#import <core.h>
#import <common.h>
#import <expr.h>
#import <graphics.h>
#import <lattice.h>
#import <layout.h>
#import <service.h>
#import <svg.h>
#import <widgets.h>
#import <support.h>
#import <network.h>
#import <binding.h>
#import <platform.h>

#import <ScadeKit-Swift.h>

#else

//! Project version number for ScadeKit
FOUNDATION_EXPORT double ScadeKit_VersionNumber;

//! Project version string for ScadeKit
FOUNDATION_EXPORT const unsigned char ScadeKit_VersionString[];

// In this header, you should import all the public headers of your framework
// using statements like #import <ScadeKit/PublicHeader.h>

#import <ScadeKit/ecore.h>
#import <ScadeKit/core.h>
#import <ScadeKit/common.h>
#import <ScadeKit/expr.h>
#import <ScadeKit/graphics.h>
#import <ScadeKit/lattice.h>
#import <ScadeKit/layout.h>
#import <ScadeKit/service.h>
#import <ScadeKit/svg.h>
#import <ScadeKit/widgets.h>
#import <ScadeKit/support.h>
#import <ScadeKit/network.h>
#import <ScadeKit/binding.h>
#import <ScadeKit/platform.h>

#import <ScadeKit/ScadeKit-Swift.h>

#endif
