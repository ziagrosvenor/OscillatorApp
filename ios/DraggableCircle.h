#include <Foundation/Foundation.h>
#include <UIKit/UIKit.h>

@interface DraggableCircle : UIView

@property (nonatomic, assign) CGPoint initialCenter;
@property (nonatomic, assign) CGFloat dragOffsetForTransparency;

@end
