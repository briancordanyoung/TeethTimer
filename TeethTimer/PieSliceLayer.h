//
//  PieSliceLayer.h
//  PieChart
//
//  Created by Pavan Podila on 2/20/12.
//  Copyright (c) 2012 Pixel-in-Gene. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface PieSliceLayer : CALayer


@property (nonatomic) CGFloat angleWidth;
@property (nonatomic) CGFloat percentCoverage;

@property (nonatomic) BOOL usePercentage;
@property (nonatomic) BOOL clipToCircle;
@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic) CGFloat strokeWidth;
@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic) CGImageRef CGImage;
@end
