//
//  ColorImage.swift
//  TeethTimer
//
//  Created by Brian Cordan Young on 12/1/14.
//  Copyright (c) 2014 Brian Young. All rights reserved.
//

import UIKit

class ColorImage: NSObject {
    
    class func colorizeImage(image: UIImage, withColor color: UIColor) -> UIImage {
        UIGraphicsBeginImageContext(image.size)
        let context = UIGraphicsGetCurrentContext()

        let area = CGRectMake(0, 0, image.size.width, image.size.height)

        CGContextScaleCTM(context, 1, -1)

        CGContextTranslateCTM(context, 0, -area.size.height)

        CGContextSaveGState(context)

        CGContextClipToMask(context, area, image.CGImage)

        color.set()

        CGContextFillRect(context, area)

        CGContextRestoreGState(context)

        CGContextSetBlendMode(context, kCGBlendModeMultiply)

        CGContextDrawImage(context, area, image.CGImage)

        let colorizedImage = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return colorizedImage
    }
    
    
}