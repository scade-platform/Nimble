#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, SCDLatticePageTransition) {
  SCDLatticePageTransitionForward_push = 0,
  SCDLatticePageTransitionBackward_push = 1
};

typedef NS_ENUM(NSInteger, SCDLatticeScreenOrientation) {
  SCDLatticeScreenOrientationPortrait = 0,
  SCDLatticeScreenOrientationLandscape = 1
};


#import <ScadeKit/SCDLatticeView.h>

#import <ScadeKit/SCDLatticeWindow.h>

#import <ScadeKit/SCDLatticePageAdapter.h>

#import <ScadeKit/SCDLatticePageContainer.h>

#import <ScadeKit/SCDLatticeSizeChangedEvent.h>

#import <ScadeKit/SCDLatticeSizeChangeHandler.h>


#import <ScadeKit/SCDLatticeSystem.h>

#import <ScadeKit/SCDLatticeOpenUrlHandler.h>

#import <ScadeKit/SCDLatticeApplicationEventHandler.h>


#import <ScadeKit/SCDLatticeEntryPoint.h>

#import <ScadeKit/SCDLatticeExitPoint.h>

#import <ScadeKit/SCDLatticeChanel.h>

#import <ScadeKit/SCDLatticePoint.h>

#import <ScadeKit/SCDLatticeNavigation.h>
