#import "BandManager.h"

@implementation BandManager

RCT_EXPORT_MODULE()

- (UIView *)view {
  return [[Band alloc] init];
}

RCT_EXPORT_VIEW_PROPERTY(idx, int)

@end
