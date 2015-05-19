//
//  CEMovieMaker.m
//  CEMovieMaker
//
//  Created by Cameron Ehrlich on 9/17/14.
//  Copyright (c) 2014 Cameron Ehrlich. All rights reserved.
//

#import "BDYVideoHelper.h"

@implementation BDYVideoHelper : NSObject 


+ (CVPixelBufferRef)newPixelBufferFromImage:(UIImage *)image
{
  
  CGImageRef cgimage = [image CGImage];
  
  CGFloat frameHeight = image.size.height;
  CGFloat frameWidth = image.size.width;

  NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                           [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                           nil];
  
  CVPixelBufferRef pxbuffer = NULL;
  

  CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                        frameWidth,
                                        frameHeight,
                                        kCVPixelFormatType_32ARGB,
                                        (__bridge CFDictionaryRef) options,
                                        &pxbuffer);
  
  NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
  
  CVPixelBufferLockBaseAddress(pxbuffer, 0);
  void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
  NSParameterAssert(pxdata != NULL);
  
  CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
  
  CGContextRef context = CGBitmapContextCreate(pxdata,
                                               frameWidth,
                                               frameHeight,
                                               8,
                                               4 * frameWidth,
                                               rgbColorSpace,
                                               (CGBitmapInfo)kCGImageAlphaNoneSkipFirst);
  NSParameterAssert(context);
  CGContextConcatCTM(context, CGAffineTransformIdentity);
  CGContextDrawImage(context, CGRectMake(0,
                                         0,
                                         CGImageGetWidth(cgimage),
                                         CGImageGetHeight(cgimage)),
                      cgimage);
  CGColorSpaceRelease(rgbColorSpace);
  CGContextRelease(context);
  
  CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
  
  return pxbuffer;
}

+ (NSDictionary *)videoSettingsWithCodec:(NSString *)codec withWidth:(CGFloat)width andHeight:(CGFloat)height
{
    
    if ((int)width % 16 != 0 ) {
        NSLog(@"Warning: video settings width must be divisible by 16.");
    }
    
    NSDictionary *videoSettings = @{AVVideoCodecKey : AVVideoCodecH264,
                                    AVVideoWidthKey : [NSNumber numberWithInt:(int)width],
                                    AVVideoHeightKey : [NSNumber numberWithInt:(int)height]};
    
    return videoSettings;
}

@end
