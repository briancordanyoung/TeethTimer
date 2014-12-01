//
//  ImageWheelControl.swift
//  TeethTimer
//
//  Created by Brian Cordan Young on 11/28/14.
//  Copyright (c) 2014 Brian Young. All rights reserved.
//

import UIKit

// TODO: Replace Delegate with target/action pattern
protocol ImageWheelDelegate {
    func wheelDidChangeValue(newValue: String)
}


class ImageWheelControl: UIControl  {
    
    var delegate: ImageWheelDelegate?
    var container = UIView()
    var numberOfSections = 6
    var startTransform = CGAffineTransformMakeRotation(0)
    var leaves: [ImageWheelLeaf] = []
    var currentValue: Int = 0
    var deltaAngle = CGFloat(0)

    let minAlphavalue: CGFloat = 1.0
    let maxAlphavalue: CGFloat = 1.0
    let centerCircle:  Float = 20.0
    var outsideCircle: Float {
        get {
            return Float(Float(container.bounds.height) * 2)
        }
    }
    

    init( WithFrame            frame: CGRect,
          AndDelegate     delegateIn: ImageWheelDelegate,
          WithSections sectionsCount: Int) {
            
        super.init(frame: frame)
            
        numberOfSections = sectionsCount
        delegate = delegateIn
        drawWheel()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: Setup Methods
    func drawWheel() {
        let angleSize: CGFloat = CGFloat(2) * CGFloat(M_PI) / CGFloat(numberOfSections)
        
        // Build UIViews for each pie piece
        for i in 0..<numberOfSections {
            let image = UIImageView(image: UIImage(named: "segment"))
            
            image.layer.anchorPoint = CGPoint(x: 1, y: 0.5)
            image.transform = CGAffineTransformMakeRotation(angleSize * CGFloat(i))
            image.alpha = minAlphavalue
            image.tag = i
            
            if (i == 0) {
                image.alpha = maxAlphavalue;
            }
            container.addSubview(image)
        }
        
        
        container.userInteractionEnabled = false
        self.addSubview(container)
        
        if (numberOfSections % 2 == 0) {
            self.buildLeafsEven()
        } else {
            self.buildLeafsOdd()
        }
        
        updateDelegatesLeafName()
    }
    
    
    
    // MARK: Contraint setup
    func positionViews() {
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        container.setTranslatesAutoresizingMaskIntoConstraints(false)

        // constraints
        let viewsDictionary = ["controlView":container]
        
        //position constraints
        let view_constraint_H:NSArray = NSLayoutConstraint.constraintsWithVisualFormat("H:|[controlView]|",
                      options: NSLayoutFormatOptions(0),
                      metrics: nil,
                        views: viewsDictionary)
        
        let view_constraint_V:NSArray = NSLayoutConstraint.constraintsWithVisualFormat("V:|[controlView]|",
                      options: NSLayoutFormatOptions(0),
                      metrics: nil,
                        views: viewsDictionary)
        
        self.addConstraints(view_constraint_H)
        self.addConstraints(view_constraint_V)

        for i in 0..<numberOfSections {
            if let image = getLeafByValue(i) {
        
                image.setTranslatesAutoresizingMaskIntoConstraints(false)
    
                container.addConstraint(NSLayoutConstraint(item: image,
                    attribute: NSLayoutAttribute.CenterY,
                    relatedBy: NSLayoutRelation.Equal,
                       toItem: container,
                    attribute: NSLayoutAttribute.CenterY,
                    multiplier: 1.0,
                     constant: 0.0))
    
                container.addConstraint(NSLayoutConstraint(item: image,
                    attribute: NSLayoutAttribute.CenterX,
                    relatedBy: NSLayoutRelation.Equal,
                       toItem: container,
                    attribute: NSLayoutAttribute.CenterX,
                    multiplier: 1.0,
                    constant: 0.0))
    
                image.addConstraint( NSLayoutConstraint(item: image,
                    attribute: NSLayoutAttribute.Height,
                    relatedBy: NSLayoutRelation.Equal,
                       toItem: nil,
                    attribute: NSLayoutAttribute.NotAnAttribute,
                    multiplier: 1.0,
                     constant: 80.0))
    
                image.addConstraint( NSLayoutConstraint(item: image,
                    attribute: NSLayoutAttribute.Width,
                    relatedBy: NSLayoutRelation.Equal,
                       toItem: nil,
                    attribute: NSLayoutAttribute.NotAnAttribute,
                    multiplier: 1.0,
                     constant: 80.0))
            }
        }
    }
    
    // MARK: Delegate Callbacks
    func updateDelegatesLeafName() {
        if let delegateUR = delegate? {
            let leafName = getLeafName(currentValue)
            delegateUR.wheelDidChangeValue(leafName)
        }

    }
    
    func buildLeafsEven() {
        let fanWidth = Float(2) * Float(M_PI) / Float(numberOfSections)
        var mid = Float(0)
        var max = Float(0)
        var min = Float(0)
        
        for i in 0..<numberOfSections {
            max = mid + (fanWidth / 2)
            min = mid - (fanWidth / 2)

            var leaf = ImageWheelLeaf(WithMin: min,
                                         AndMax: max,
                                         AndMid: mid,
                                       AndValue: i)
            
            if (leaf.maxValue - fanWidth < Float(M_PI * -1)) {
                mid = Float(M_PI)
                leaf.midValue = mid
                leaf.minValue = fabsf(leaf.maxValue)
            }
            
            mid -= fanWidth
            
//            println("cl is \(leaf)");
            
            leaves.append(leaf)
        }
    }
    
    
    func buildLeafsOdd() {
        let fanWidth = Float(2) * Float(M_PI) / Float(numberOfSections)
        var mid = Float(0)
        var max = Float(0)
        var min = Float(0)

        
        for i in 0..<numberOfSections {
            max = mid + (fanWidth / 2)
            min = mid - (fanWidth / 2)

            var leaf = ImageWheelLeaf(WithMin: min,
                                         AndMax: max,
                                         AndMid: mid,
                                       AndValue: i)
            
            mid -= fanWidth

            if (leaf.maxValue < Float(-M_PI)) {
                mid = (mid * -1)
                mid -= fanWidth
            }
            
//            println("cl is \(leaf)");
            
            leaves.append(leaf)
        }
    }
    
    
    // MARK: UIControl methods
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        let touchPoint = touch.locationInView(self)
        let dist = calculateDistanceFromCenter(touchPoint)
        
        if (dist < centerCircle || dist > outsideCircle) {
            // forcing a tap to be on the ferrule
            println("ignoring tap (\(touchPoint.x),\(touchPoint.y))")
            return false
        }
        
        let dx = touchPoint.x - container.center.x
        let dy = touchPoint.y - container.center.y
        deltaAngle = atan2(dy,dx)
        startTransform = container.transform
        getLeafByValue(currentValue)?.alpha = minAlphavalue
        
        return true
    }
    
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        let touchPoint = touch.locationInView(self)
        
        let dist = calculateDistanceFromCenter(touchPoint)

        if (dist < centerCircle || dist > outsideCircle) {
            // a drag path too close to the center
//            println("drag path too close to the center (\(touchPoint.x),\(touchPoint.y))");
            
            // here you might want to implement your solution when the drag
            // is too close to the center
            // You might go back to the leaf previously selected
            // or you might calculate the leaf corresponding to
            // the "exit point" of the drag.
            
        }
        
        let dx = touchPoint.x - container.center.x
        let dy = touchPoint.y - container.center.y
        let ang = atan2(dy,dx)
        
        let angleDifference = deltaAngle - ang
        
        container.transform = CGAffineTransformRotate(startTransform, -angleDifference)
        
        return true
    }

    
    override func endTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) {
        let b = Float(container.transform.b)
        let a = Float(container.transform.a)
        let radians = atan2f(b, a)
        
        var newVal = CGFloat(0)
        
        for c in leaves {
            if (c.minValue > 0.0 && c.maxValue < 0.0) { // anomalous case
                
                if (c.maxValue > radians || c.minValue < radians) {
                    if (radians > 0.0) { // we are in the positive quadrant
                        newVal = CGFloat(radians) - CGFloat(M_PI);
                    } else { // we are in the negative one
                        newVal = CGFloat(radians) + CGFloat(M_PI);
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
        
        let t = CGAffineTransformRotate(container.transform, (newVal * -1))
        container.transform = t;
        
        UIView.commitAnimations()
        
        updateDelegatesLeafName()
        
        getLeafByValue(currentValue)?.alpha = maxAlphavalue
    }
    
    
    
    // MARK: Helper method
    func getLeafName(position: Int) -> String {
        
        var name = ""
        
        switch (position) {

        case 0:
            name = "0"
            
        case 1:
            name = "1"
            
        case 2:
            name = "2"
            
        case 3:
            name = "3"
            
        case 4:
            name = "4"
            
        case 5:
            name = "5"
            
        case 6:
            name = "6"
            
        case 7:
            name = "7"
            
        case 8:
            name = "Triangle"
            
        default:
            name = "more than 8"
        }
        
        return name
    }
    
    func getLeafByValue(value: Int) -> UIImageView? {
        
        var leafView: UIImageView?
        let views = container.subviews
        
        for image in views {
            let imageView = image as UIImageView
            if imageView.tag == value {
                leafView = imageView
            }
        }
        
        return leafView
    }
    
    func calculateDistanceFromCenter(point: CGPoint) -> Float {
        let center = CGPointMake(self.bounds.size.width  / 2.0,
                                 self.bounds.size.height / 2.0)
        
        return distanceBetweenPointA(center, AndPointB: point)
    }
    
    func distanceBetweenPointA(pointA: CGPoint, AndPointB pointB: CGPoint) -> Float {
        let dx = pointA.x - pointB.x
        let dy = pointA.y - pointB.y
        let sqrtOf = Float(dx * dx + dy * dy)
        
        return sqrt(sqrtOf)
    }
    
}

