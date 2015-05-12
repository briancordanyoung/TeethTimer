//
//  FramesToMovie.m
//  TeethTimer
//
//  Created by Brian Cordan Young on 5/11/15.
//  Copyright (c) 2015 Brian Young. All rights reserved.
//

#import "FramesToMovie.h"

@implementation FramesToMovie

@synthesize arrImages;

- (void) writeImagesAsMovie:(NSString*)path
{
  NSError *error  = nil;
  UIImage *first = [arrImages objectAtIndex:0];
  CGSize frameSize = first.size;
  AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:
                                [NSURL fileURLWithPath:path] fileType:AVFileTypeQuickTimeMovie
                                                            error:&error];
  NSParameterAssert(videoWriter);
  
  NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                 AVVideoCodecH264, AVVideoCodecKey,
                                 [NSNumber numberWithInt:640], AVVideoWidthKey,
                                 [NSNumber numberWithInt:480], AVVideoHeightKey,
                                 nil];
  AVAssetWriterInput* writerInput = [AVAssetWriterInput
                                      assetWriterInputWithMediaType:AVMediaTypeVideo
                                      outputSettings:videoSettings];
  
  AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                   assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput
                                                   sourcePixelBufferAttributes:nil];
  
  NSParameterAssert(writerInput);
  NSParameterAssert([videoWriter canAddInput:writerInput]);
  [videoWriter addInput:writerInput];
  
  [videoWriter startWriting];
  [videoWriter startSessionAtSourceTime:kCMTimeZero];
  
  int frameCount = 0;
  CVPixelBufferRef buffer = NULL;
  for(UIImage *img in arrImages)
  {
    buffer = [self newPixelBufferFromCGImage:[img CGImage] andFrameSize:frameSize];
    
    if (adaptor.assetWriterInput.readyForMoreMediaData)
    {
      CMTime frameTime = CMTimeMake(frameCount,(int32_t) kRecordingFPS);
      [adaptor appendPixelBuffer:buffer withPresentationTime:frameTime];
      
      if(buffer)
        CVBufferRelease(buffer);
    }
    frameCount++;
  }
  
  [writerInput markAsFinished];
  [videoWriter finishWriting];
}


- (CVPixelBufferRef) newPixelBufferFromCGImage: (CGImageRef) image andFrameSize:(CGSize)frameSize
{
  NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                           [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                           nil];
  CVPixelBufferRef pxbuffer = NULL;
  CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, frameSize.width,
                                        frameSize.height, kCVPixelFormatType_32ARGB, (CFDictionaryRef) options,
                                        &pxbuffer);
  NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
  
  CVPixelBufferLockBaseAddress(pxbuffer, 0);
  void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
  NSParameterAssert(pxdata != NULL);
  
  CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
  CGContextRef context = CGBitmapContextCreate(pxdata, frameSize.width,
                                               frameSize.height, 8, 4*frameSize.width, rgbColorSpace,
                                               kCGImageAlphaNoneSkipFirst);
  NSParameterAssert(context);
  CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
  CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
                                         CGImageGetHeight(image)), image);
  CGColorSpaceRelease(rgbColorSpace);
  CGContextRelease(context);
  
  CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
  
  return pxbuffer;
}


@end
