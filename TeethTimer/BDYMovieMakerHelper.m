#import "BDYMovieMakerHelper.h"

@implementation BDYMovieMakerHelper : NSObject 


+ (CVPixelBufferRef)newPixelBufferFromImage:(UIImage *)image
{
  
  CGImageRef cgimage = [image CGImage];
  
  CGFloat frameHeight = image.size.height;
  CGFloat frameWidth  = image.size.width;

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
  CGRect rect = CGRectMake(0,
                           0,
                           CGImageGetWidth(cgimage),
                           CGImageGetHeight(cgimage));
  
  CGContextDrawImage(context, rect, cgimage);
  CGColorSpaceRelease(rgbColorSpace);
  CGContextRelease(context);
  
  CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
  
  return pxbuffer;
}

@end
