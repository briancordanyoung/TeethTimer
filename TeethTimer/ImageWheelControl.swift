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
    var currentLeafValue: Int = 0
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
        startTransform = CGAffineTransformMakeRotation(360.0 / CGFloat(numberOfSections) / 2.0)
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
        for i in 1...numberOfSections {
            var image = UIImage(named: "segment")
            
            if i == 1 {
                image = ColorImage.colorizeImage(image!, withColor: UIColor.blackColor())
            }

            if i == 2 {
                image = ColorImage.colorizeImage(image!, withColor: UIColor.redColor())
            }

            if i == 10 {
                image = ColorImage.colorizeImage(image!, withColor: UIColor.blueColor())
            }
            

            var imageView = UIImageView(image: image)
            
            imageView.layer.anchorPoint = CGPoint(x: 1, y: 0.5)
            imageView.transform = CGAffineTransformMakeRotation(angleSize * CGFloat(i + 1))
            imageView.tag = i
            
            container.addSubview(imageView)
        }
        
        
        container.userInteractionEnabled = false
        self.addSubview(container)
        
        if (numberOfSections % 2 == 0) {
            self.buildLeavesEven()
        } else {
            self.buildLeavesOdd()
        }
        
        updateDelegatesLeafName()
    }
    
    func buildLeavesEven() {
        let leafWidth = Float(2) * Float(M_PI) / Float(numberOfSections)
        var mid = leafWidth / 2 
        var max = Float(0)
        var min = Float(0)
        
        for i in 1...numberOfSections {
            max = mid + (leafWidth / 2)
            min = mid - (leafWidth / 2)
            
            var leaf = ImageWheelLeaf(WithMin: min,
                                       AndMax: max,
                                       AndMid: mid,
                                     AndValue: i)
            
            if (leaf.maxRadian - leafWidth < Float(M_PI * -1)) {
                mid = Float(M_PI) - (leafWidth / 2)
                leaf.midRadian = mid
                leaf.minRadian = fabsf(leaf.maxRadian)
            }
            
            mid -= leafWidth
            
            println("Leaf: \(leaf.description())");
            
            leaves.append(leaf)
        }
    }
    
    
    func buildLeavesOdd() {
        let leafWidth = Float(2) * Float(M_PI) / Float(numberOfSections)
        var mid = Float(0) //leafWidth / 2
        var max = Float(0)
        var min = Float(0)
        
        
        for i in 1...numberOfSections {
            max = mid + (leafWidth / 2)
            min = mid - (leafWidth / 2)
            
            var leaf = ImageWheelLeaf(WithMin: min,
                                       AndMax: max,
                                       AndMid: mid,
                                     AndValue: i)
            
            mid -= leafWidth
            
            if (leaf.maxRadian < Float(-M_PI)) {
                mid = (mid * -1)
                mid -= leafWidth
            }
            
            println("Leaf: \(leaf.description())");
            
            leaves.append(leaf)
        }
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

        for i in 1...numberOfSections {
            if let image = getLeafImageByValue(i) {
        
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
                     constant: 200.0))
            }
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
        getLeafImageByValue(currentLeafValue)?.alpha = minAlphavalue
        
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
        let currentRotation = radiansFromTransform(container.transform)
        
        var newRotation = CGFloat(0)
        
        for leaf in leaves {
            if (leaf.minRadian > 0.0 && leaf.maxRadian < 0.0) { // anomalous case
                
                if (leaf.maxRadian > currentRotation || leaf.minRadian < currentRotation) {
                    if (currentRotation > 0.0) { // we are in the positive quadrant
                        newRotation = CGFloat(currentRotation) - CGFloat(M_PI);
                    } else { // we are in the negative one
                        newRotation = CGFloat(currentRotation) + CGFloat(M_PI);
                    }
                    currentLeafValue = leaf.value;
                }
                
            } else if (currentRotation > leaf.minRadian && currentRotation < leaf.maxRadian) {
                
                newRotation = CGFloat(currentRotation) - CGFloat(leaf.midRadian);
                currentLeafValue = leaf.value;
                
            }
        }
        
//        println("newRotation set: \(newRotation)")
        
        
        animateImageWheelRotationByRadians(newRotation * -1)
        updateDelegatesLeafName()
    }
    
    func rotateToLeafByValue(value: Int) {
        if let leaf = getLeafByValue(value) {
            println(" | \(value)")
            rotateToLeaf(leaf)
        }
    }
    
    func rotateToLeaf(leaf: ImageWheelLeaf) {
        let currentRotation = radiansFromTransform(container.transform)
        let newRotation = CGFloat(currentRotation) - CGFloat(leaf.midRadian);
        animateImageWheelRotationByRadians(newRotation * -1)
        
        currentLeafValue = leaf.value;
        updateDelegatesLeafName()
    }
    
    
    func animateImageWheelRotationByRadians(radians: CGFloat) {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.2)
        
        let t = CGAffineTransformRotate(container.transform, radians)
        container.transform = t;
        
        UIView.commitAnimations()
    }
    
    
    // MARK: Delegate Callbacks
    func updateDelegatesLeafName() {
        if let delegateUR = delegate? {
            let leafName = getLeafName(currentLeafValue)
            delegateUR.wheelDidChangeValue(leafName)
        }
        
    }
    
    // MARK: Helper method
    func getLeafName(position: Int) -> String {
        
        var name = ""
        
        switch (position) {

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
            name = "8"
            
        case 9:
            name = "9"
            
        case 10:
            name = "10"
            
        default:
            name = "more than 10"
        }
        
        return name
    }
    
    func getLeafImageByValue(value: Int) -> UIImageView? {
        
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
    
    func getLeafByValue(value: Int) -> ImageWheelLeaf? {
        
        var returnLeaf: ImageWheelLeaf?
        
        for leaf in leaves {
            if leaf.value == value {
                returnLeaf = leaf
            }
        }
        
        return returnLeaf
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
    
    func radiansFromTransform(transform: CGAffineTransform) -> Float {
        let b = Float(transform.b)
        let a = Float(transform.a)
        let radians = atan2f(b, a)
        
        return radians
    }

}

