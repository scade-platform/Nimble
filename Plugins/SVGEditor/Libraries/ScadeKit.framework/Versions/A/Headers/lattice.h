#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, SCDLatticeScreenOrientation) {
  SCDLatticeScreenOrientationPortrait = 0,
  SCDLatticeScreenOrientationLandscape = 1
};

typedef NS_ENUM(NSInteger, SCDLatticeTransition) {
  SCDLatticeTransitionFromLeft = 0,
  SCDLatticeTransitionFromRight = 1,
  SCDLatticeTransitionFromTop = 2,
  SCDLatticeTransitionFromBottom = 3
};


#import <ScadeKit/SCDLatticeView.h>

#import <ScadeKit/SCDLatticeWindow.h>

#import <ScadeKit/SCDLatticePageAdapter.h>

#import <ScadeKit/SCDLatticeEditorPageAdapter.h>

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
