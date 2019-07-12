#import <Foundation/Foundation.h>

#import <ScadeKit/EObject.h>


@class SCDWidgetsPage;
@class SCDLatticeEntryPoint;
@class SCDLatticeExitPoint;


/*PROTECTED REGION ID(aef05a273263a514b366d5ea66b86a7b) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/


SCADE_API
@interface SCDLatticeNavigation : EObject


@property(nonatomic) SCDWidgetsPage* _Nullable page;

@property(nonatomic) NSArray<SCDLatticeEntryPoint*>* _Nonnull entryPoints;

@property(nonatomic) NSArray<SCDLatticeExitPoint*>* _Nonnull exitPoints;


- (void)go:(NSString* _Nonnull)page;

- (void)go:(NSString* _Nonnull)page transition:(NSString* _Nonnull)transition;

- (void)goWith:(NSString* _Nonnull)page data:(id _Nullable)data;

- (void)goWith:(NSString* _Nonnull)page
          data:(id _Nullable)data
    transition:(NSString* _Nonnull)transition;

- (SCDLatticeEntryPoint* _Nullable)getEntryPoint:(NSString* _Nonnull)name;

- (SCDLatticeExitPoint* _Nullable)getExitPoint:(NSString* _Nonnull)name;


/*PROTECTED REGION ID(18648f5be7ad41842351db7610a80ed3) START*/
// Please, enable the protected region if you add manually written code.
// To do this, add the keyword ENABLED before START.
/*PROTECTED REGION END*/

@end
