//
//  ImageWheelControl.swift
//  TeethTimer
//
//  Created by Brian Cordan Young on 11/28/14.
//  Copyright (c) 2014 Brian Young. All rights reserved.
//

import UIKit

protocol ImageWheelDelegate {
    func wheelDidChangeValue(newValue: String)
}


class ImageWheelControl: UIControl  {
    
    var delegate: ImageWheelDelegate?
    var container: UIView?
    var numberOfSections = 8
    var startTransform = CGAffineTransformMakeRotation(0)
    var cloves: [ImageWheelClove] = []
    var currentValue: Int = 0
    var deltaAngle = CGFloat(0)

    let minAlphavalue: CGFloat = 0.6
    let maxAlphavalue: CGFloat  = 1.0
    let cloveRect: CGRect = CGRectMake(12.0, 15.0, 40.0, 40.0)
    
    
    init(WithFrame frame: CGRect, AndDelegate delegateIn: ImageWheelDelegate, withSections sectionsNumber: Int) {
        super.init(frame: frame)
        numberOfSections = sectionsNumber
        container = UIView(frame: self.frame)
        delegate = delegateIn
        self.drawWheel()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        
    }

    func drawWheel() {
        let angleSize: CGFloat = CGFloat(2) * CGFloat(M_PI) / CGFloat(numberOfSections)
        
        // Build UIViews for each pie piece
        for i in 0..<numberOfSections {
            let image = UIImageView(image: UIImage(named: "segment"))
            
            image.layer.anchorPoint = CGPoint(x: 1, y: 0.5)
            image.layer.position = CGPoint(x: container!.bounds.size.width/2.0-container!.frame.origin.x,
                                           y: container!.bounds.size.height/2.0-container!.frame.origin.y)
            image.transform = CGAffineTransformMakeRotation(angleSize * CGFloat(i))
            image.alpha = minAlphavalue
            image.tag = i
            
            if (i == 0) {
                image.alpha = maxAlphavalue;
            }
            
            let cloveImage = UIImageView(frame: cloveRect)
            let imageName = "icon\(i).png"
            cloveImage.image = UIImage(named: imageName)
            image .addSubview(cloveImage)
            
            container?.addSubview(image)
            
        }
        
        
        container!.userInteractionEnabled = false
        self.addSubview(container!)
        
        let backgroundImage = UIImageView(frame: self.frame)
        backgroundImage.image = UIImage(named: "bg")
        self .addSubview(backgroundImage)
        
        let mask = UIImageView(frame: CGRectMake(0.0, 0.0, 58.0, 58.0))
        mask.image = UIImage(named: "centerButton")
        mask.center = self.center
        mask.center = CGPointMake(mask.center.x, mask.center.y + 3)
        self.addSubview(mask)
        
        if (numberOfSections % 2 == 0) {
            
            self.buildClovesEven()
            
        } else {
            
            self.buildClovesOdd()
            
        }
        
        self.delegate!.wheelDidChangeValue(getCloveName(currentValue))

    }
    
    func getCloveByValue(value: Int) -> UIImageView {
        
        var res = UIImageView()
        
        let views = container!.subviews
        
        for image in views {
            let imageView = image as UIImageView
            if imageView.tag == value {
                res = imageView
            }
        }
        
        return res
    }
    
    func buildClovesEven() {
        let fanWidth = Float(2) * Float(M_PI) / Float(numberOfSections)
        var mid = Float(0)
        var max = Float(0)
        var min = Float(0)
        
        for i in 0..<numberOfSections {
            max = mid + (fanWidth / 2)
            min = mid - (fanWidth / 2)

            var clove = ImageWheelClove(WithMin: min,
                                         AndMax: max,
                                         AndMid: mid,
                                       AndValue: i)
            
            if (clove.maxValue - fanWidth < Float(M_PI * -1)) {
                mid = Float(M_PI)
                clove.midValue = mid
                clove.minValue = fabsf(clove.maxValue)
            }
            
            mid -= fanWidth
            
            println("cl is \(clove)");
            
            cloves.append(clove)
        }
    }
    
    
    func buildClovesOdd() {
        let fanWidth = Float(2) * Float(M_PI) / Float(numberOfSections)
        var mid = Float(0)
        var max = Float(0)
        var min = Float(0)

        
        for i in 0..<numberOfSections {
            max = mid + (fanWidth / 2)
            min = mid - (fanWidth / 2)

            var clove = ImageWheelClove(WithMin: min,
                                         AndMax: max,
                                         AndMid: mid,
                                       AndValue: i)
            
            mid -= fanWidth

            if (clove.maxValue < Float(-M_PI)) {
                mid = (mid * -1)
                mid -= fanWidth
            }
            
            println("cl is \(clove)");
            
            cloves.append(clove)
        }
    }
    
    
    func calculateDistanceFromCenter(point: CGPoint) -> Float {
        let center = CGPointMake(self.bounds.size.width  / 2.0,
                                 self.bounds.size.height / 2.0)
        let dx = point.x - center.x
        let dy = point.y - center.y
        let sqrtOf = Float(dx * dx + dy * dy)
        
        return sqrt(sqrtOf)
    }
    
    // MARK: UIControl methods
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        let touchPoint = touch.locationInView(self)
        let dist = calculateDistanceFromCenter(touchPoint)
        
        if (dist < 40 || dist > 100) {
            // forcing a tap to be on the ferrule
            println("ignoring tap (\(touchPoint.x),\(touchPoint.y))")
            return false
        }
        
        let dx = touchPoint.x - container!.center.x
        let dy = touchPoint.y - container!.center.y
        deltaAngle = atan2(dy,dx)

        startTransform = container!.transform
        
        let image = getCloveByValue(currentValue)
        image.alpha = minAlphavalue
        
        return true
    }
    
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        let pt = touch.locationInView(self)
        
        let dist = calculateDistanceFromCenter(pt)

        if (dist < 40 || dist > 100) {
            // a drag path too close to the center
            println("drag path too close to the center (\(pt.x),\(pt.y))");
            
            // here you might want to implement your solution when the drag
            // is too close to the center
            // You might go back to the clove previously selected
            // or you might calculate the clove corresponding to
            // the "exit point" of the drag.
            
        }
        
        let dx = pt.x - container!.center.x
        let dy = pt.y - container!.center.y
        let ang = atan2(dy,dx)
        
        let angleDifference = deltaAngle - ang
        
        container!.transform = CGAffineTransformRotate(startTransform, -angleDifference)
        
        return true
    }

    
    override func endTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) {
        let b = Float(container!.transform.b)
        let a = Float(container!.transform.a)
        let radians = atan2f(b, a)
        
        var newVal = CGFloat(0)
        
        
        for c in cloves {
            if (c.minValue > 0.0 && c.maxValue < 0.0) { // anomalous case
                
                if (c.maxValue > radians || c.minValue < radians) {
                    
                    if (radians > 0.0) { // we are in the positive quadrant
                        
                        newVal = CGFloat(radians) - CGFloat(M_PI);
                        
                    } else { // we are in the negative one
                        
                        newVal = CGFloat(M_PI) + CGFloat(radians);
                        
                    }

                    currentValue = c.value;
                    
                }
                
            }
        
            else if (radians > c.minValue && radians < c.maxValue) {
                
                newVal = CGFloat(radians) - CGFloat(c.midValue);

                currentValue = c.value;
                
            }
        }
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.2)
        
        let t = CGAffineTransformRotate(container!.transform, (newVal * -1))
        container!.transform = t;
        
        UIView.commitAnimations()
        
        delegate!.wheelDidChangeValue(getCloveName(currentValue))
        
        let image = getCloveByValue(currentValue)
        image.alpha = maxAlphavalue

    }
    
    // MARK: Helper method
    func getCloveName(position: Int) -> String {
        
        var res = ""
        
        switch (position) {

        case 0:
            res = "Circles"
            
        case 1:
            res = "Flower"
            
        case 2:
            res = "Monster"
            
        case 3:
            res = "Person"
            
        case 4:
            res = "Smile"
            
        case 5:
            res = "Sun"
            
        case 6:
            res = "Swirl"
            
        case 7:
            res = "3 circles"
            
        case 8:
            res = "Triangle"
            
        default:
            res = ""
        }
        
        return res
    }
    
}

