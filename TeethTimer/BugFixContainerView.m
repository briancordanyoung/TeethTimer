#import "BugFixContainerView.h"

@implementation BugFixContainerView
- (void)layoutSubviews
{
  static CGPoint fixCenter = {0};
  [super layoutSubviews];
  if (CGPointEqualToPoint(fixCenter, CGPointZero)) {
    fixCenter = [self.wheelControl center];
    NSLog(@"Setting fixCenter");
  } else {
    self.wheelControl.center = fixCenter;
    NSLog(@"Setting wheelControl.center");
  }
}
@end
