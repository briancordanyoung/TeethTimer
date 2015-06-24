//
//  PieSliceLayer.m
//  PieChart
//
//  Created by Pavan Podila on 2/20/12.
//  Copyright (c) 2012 Pixel-in-Gene. All rights reserved.
//

#import "PieSliceLayer.h"


CGImageRef flip (CGImageRef im) {
  CGSize sz = CGSizeMake(CGImageGetWidth(im), CGImageGetHeight(im));
  UIGraphicsBeginImageContextWithOptions(sz, NO, 0);
  CGContextDrawImage(UIGraphicsGetCurrentContext(),
                     CGRectMake(0, 0, sz.width, sz.height), im);
  CGImageRef result = [UIGraphicsGetImageFromCurrentImageContext() CGImage];
  UIGraphicsEndImageContext();
  return result;
}


@implementation PieSliceLayer

@dynamic angleWidth;
@dynamic percentCoverage;
@synthesize usePercentage, clipToCircle;
@synthesize fillColor, strokeColor, strokeWidth;
@synthesize CGImage = _CGImage;

- (void) setCGImage:(CGImageRef)unalteredCGImage {
  CGImageRelease(_CGImage);
  CGImageRef alteredImage = nil;

  if (unalteredCGImage != nil) {
    alteredImage = flip(unalteredCGImage);
    CGImageRetain(alteredImage);
  }
  _CGImage = alteredImage;
  [self setNeedsDisplay];
}


- (CABasicAnimation *)makeAnimationForKey:(NSString *)key {
	CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:key];
	anim.fromValue = [[self presentationLayer] valueForKey:key];
	anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
	anim.duration = 0.0;

	return anim;
}

- (id)init {
    self = [super init];
    if (self) {
      self.clipToCircle  = NO;
      self.usePercentage = NO;
      self.strokeWidth   = 0.0;
      self.fillColor     = [UIColor redColor];
      self.strokeColor   = [UIColor clearColor];
      
    }
	
    return self;
}

- (void) dealloc {
  CGImageRelease(_CGImage);
}

//-(id<CAAction>)actionForKey:(NSString *)event {
//  if ([event isEqualToString:@"angleWidth"] ||
//      [event isEqualToString:@"percentCoverage"] ) {
//		return [self makeAnimationForKey:event];
//	}
//	
//	return [super actionForKey:event];
//}

- (id)initWithLayer:(id)layer {
	if (self = [super initWithLayer:layer]) {
		if ([layer isKindOfClass:[PieSliceLayer class]]) {
			PieSliceLayer *other = (PieSliceLayer *)layer;
      self.clipToCircle    = other.clipToCircle;
      self.usePercentage   = other.usePercentage;
      self.percentCoverage = other.percentCoverage;
      self.angleWidth      = other.angleWidth;
			self.fillColor       = other.fillColor;

			self.strokeColor     = other.strokeColor;
			self.strokeWidth     = other.strokeWidth;
		}
	}
	
	return self;
}

+ (BOOL)needsDisplayForKey:(NSString *)key {
  if ([key isEqualToString:@"angleWidth"] ||
      [key isEqualToString:@"percentCoverage"] ||
      [key isEqualToString:@"CGImage"]) {
		return YES;
	}
	
	return [super needsDisplayForKey:key];
}


-(void)drawInContext:(CGContextRef)ctx {
  CGImageRef mask = [self createMaskImage];
  CGContextClipToMask(ctx, self.bounds, mask);
  CGImageRelease(mask);

  if (self.CGImage == nil) {
    CGContextSetFillColorWithColor(ctx, self.fillColor.CGColor);
    CGContextFillRect(ctx, self.bounds);
  } else {
    if (self.CGImage != nil) {
      CGContextDrawImage(ctx, self.bounds, self.CGImage);
    }
  }
  
}


-(void)drawMaskInContext:(CGContextRef)ctx {
  
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
  CGPoint center = CGPointMake(self.bounds.size.width  * self.anchorPoint.x,
                               self.bounds.size.height * self.anchorPoint.y);
  
	CGFloat radius;
  if (clipToCircle) {
    radius = MIN(center.x, center.y);
  } else {
    radius = MAX(self.bounds.size.width, self.bounds.size.height);
  }
	
	CGContextBeginPath(ctx);
	CGContextMoveToPoint(ctx, center.x, center.y);
	
	CGPoint p1 = CGPointMake(center.x + radius * cosf(startAngle), center.y + radius * sinf(startAngle));
	CGContextAddLineToPoint(ctx, p1.x, p1.y);

	int clockwise = startAngle > endAngle;
	CGContextAddArc(ctx, center.x, center.y, radius, startAngle, endAngle, clockwise);

	CGContextClosePath(ctx);
	
	// Color it
	CGContextSetFillColorWithColor(ctx, self.fillColor.CGColor);
	CGContextSetStrokeColorWithColor(ctx, self.strokeColor.CGColor);
	CGContextSetLineWidth(ctx, self.strokeWidth);

	CGContextDrawPath(ctx, kCGPathFillStroke);
}




-(CGImageRef)createMaskImage {
  CGFloat width = self.bounds.size.width;
  CGFloat height = self.bounds.size.height;
  
  // Create a bitmap graphics context of the given size
  //
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGContextRef context = CGBitmapContextCreate(NULL, width,
                                                    height,
                                               8, 0, colorSpace,
                                 (CGBitmapInfo) kCGImageAlphaPremultipliedLast);

  [self drawMaskInContext: context];
  
  // Get your image
  //
  CGImageRef cgImage = CGBitmapContextCreateImage(context);
  
  CGColorSpaceRelease(colorSpace);
  CGContextRelease(context);
  
  return cgImage;

}

@end
