//
//  PieSliceLayer.m
//  PieChart
//
//  Created by Pavan Podila on 2/20/12.
//  Copyright (c) 2012 Pixel-in-Gene. All rights reserved.
//

#import "PieSliceLayer.h"

@implementation PieSliceLayer

@dynamic angleWidth;
@dynamic percentCoverage;
@synthesize usePercentage;
@synthesize fillColor, strokeColor, strokeWidth;

-(CABasicAnimation *)makeAnimationForKey:(NSString *)key {
	CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:key];
	anim.fromValue = [[self presentationLayer] valueForKey:key];
	anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
	anim.duration = 0.5;

	return anim;
}

- (id)init {
    self = [super init];
    if (self) {
		self.fillColor = [UIColor grayColor];
    self.strokeColor = [UIColor blackColor];
		self.strokeWidth = 1.0;
		
		[self setNeedsDisplay];
  }
	
  return self;
}

-(id<CAAction>)actionForKey:(NSString *)event {
	if ([event isEqualToString:@"angleWidth"] ||
      [event isEqualToString:@"percentCoverage"] ) {
		return [self makeAnimationForKey:event];
	}
	
	return [super actionForKey:event];
}

- (id)initWithLayer:(id)layer {
	if (self = [super initWithLayer:layer]) {
		if ([layer isKindOfClass:[PieSliceLayer class]]) {
			PieSliceLayer *other = (PieSliceLayer *)layer;
      self.usePercentage = NO;
      self.percentCoverage = 0.0;
      self.angleWidth = other.angleWidth;
			self.fillColor = other.fillColor;

			self.strokeColor = other.strokeColor;
			self.strokeWidth = other.strokeWidth;
		}
	}
	
	return self;
}


+ (BOOL)needsDisplayForKey:(NSString *)key {
	if ([key isEqualToString:@"angleWidth"] ||
      [key isEqualToString:@"percentCoverage"]) {
		return YES;
	}
	return [super needsDisplayForKey:key];
}


-(void)drawInContext:(CGContextRef)ctx {

  CGFloat width = 0;
  if (usePercentage) {
    width = self.percentCoverage * M_PI;
  } else {
    width = self.angleWidth;
  }
  
  // Calc Angles
  CGFloat offsetAngle = M_PI / 2;
  CGFloat angle = (width / 2) - offsetAngle;
  CGFloat startAngle = angle - width;
  CGFloat endAngle = angle;
  
  
  
  
	// Create the path
	CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
	CGFloat radius = MAX(center.x, center.y) - 1.0;
	
	CGContextBeginPath(ctx);
	CGContextMoveToPoint(ctx, center.x, center.y);
	
	CGPoint p1 = CGPointMake(center.x + radius * cosf(startAngle), center.y + radius * sinf(startAngle));
	CGContextAddLineToPoint(ctx, p1.x, p1.y);

	int clockwise = startAngle > endAngle;
	CGContextAddArc(ctx, center.x, center.y, radius, startAngle, endAngle, clockwise);

	CGContextClosePath(ctx);
	
	// Color it
	CGContextSetFillColorWithColor(ctx, self.fillColor.CGColor);
//	CGContextSetStrokeColorWithColor(ctx, self.strokeColor.CGColor);
//	CGContextSetLineWidth(ctx, self.strokeWidth);
//  CGContextSetAlpha(ctx, 1.0);
  CGContextDrawPath(ctx, kCGPathFillStroke);
  
//  CGImageRef mask = CGBitmapContextCreateImage(ctx);
//  CGContextClearRect(ctx, self.frame);
  
//  
//  if ((self.image!=nil) && YES) {
//    CGImageRef maskedImage = CGImageCreateWithMask(self.image, mask);
//
//    CATransform3D transform = self.transform;
//    self.transform = CATransform3DIdentity;
//    CGContextTranslateCTM(ctx, 0, self.bounds.size.height);
//    CGContextScaleCTM(ctx, 1.0, -1.0);
//    CGContextDrawImage(ctx, self.frame, maskedImage);
//    CGContextClipToMask(ctx, self.frame, mask);
//    self.transform = transform;
//  }
  
  // CGImageRelease(mask);
  // CGImageRelease(maskedImage);



}
@end
