//
//  CEMovieMaker.h
//  CEMovieMaker
//
//  Created by Cameron Ehrlich on 9/17/14.
//  Copyright (c) 2014 Cameron Ehrlich. All rights reserved.
//

@import AVFoundation;
@import Foundation;
@import UIKit;

typedef void(^CEMovieMakerCompletion)(NSURL *fileURL);

@interface BDYVideoHelper : NSObject

+ (CVPixelBufferRef)newPixelBufferFromImage:(UIImage *)image;

+ (NSDictionary *)videoSettingsWithCodec:(NSString *)codec withWidth:(CGFloat)width andHeight:(CGFloat)height;

@end
