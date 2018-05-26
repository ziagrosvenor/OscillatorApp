#include <Foundation/Foundation.h>
#include <UIKit/UIKit.h>

@interface Band : UIView

@property (nonatomic, assign) CGPoint initialCenter;
@property (nonatomic, assign) CGFloat dragOffsetForTransparency;

@property (nonatomic, assign) int idx;
@end
