#include <Foundation/Foundation.h>
#include <UIKit/UIKit.h>

@interface SpectrumBand : UIView

@property (nonatomic, assign) CGPoint initialCenter;
@property (nonatomic, assign) CGFloat dragOffsetForTransparency;
@end
