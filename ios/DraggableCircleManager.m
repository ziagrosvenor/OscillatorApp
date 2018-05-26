#import "DraggableCircleManager.h"

@implementation DraggableCircleManager {

}

RCT_EXPORT_MODULE()

- (UIView *)view {
  return [[DraggableCircle alloc] init];
}

RCT_EXPORT_VIEW_PROPERTY(idx, int)

@end

