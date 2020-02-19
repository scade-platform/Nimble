#import <Foundation/Foundation.h>
#import <ScadeKit/EObject.h>
#import <ScadeKit/EStructuralFeature.h>

SCADE_API
@protocol SCDNotification <NSObjectProtocol>

- (EObject*)notifier;

- (EStructuralFeature*)feature;

- (id)value;

- (id)oldValue;

- (NSUInteger)position;

- (id)key;

@end
