//
//  ImageWheelControl.swift
//  TeethTimer
//
//  Created by Brian Cordan Young on 11/28/14.
//  Copyright (c) 2014 Brian Young. All rights reserved.
//

import UIKit

typealias wheelTurnedBackByDelegate = (Int, AndPercentage: CGFloat) -> ()

class ImageWheelControl: UIControl  {
    
    let minAlphavalue: CGFloat = 1.0
    let maxAlphavalue: CGFloat = 1.0
    let centerCircle:  Float = 20.0
    let leafImageHeight: CGFloat = (800 * 0.9)
    let leafImageWidth: CGFloat = (734 * 0.9)
    
    //  3 = highly dampened
    //  6 = slightly dampened
    // 12 = no dampening
    let angleDifferenceDampenerFactor: Float = 4.5

    var container = UIView()
    var numberOfSections = 6
    var leaves: [ImageWheelLeaf] = []

    // Primary properties holding this controls data
    var currentLeafValue = 1

    // Wheel Rotation state for user interaction:
    var leafValueBeforeTouch = 1
    var returnToPreviousLeaf = false
    var previousAngle: CGFloat?
    var wheelHasFlipped360 = false
    var deltaAngle = CGFloat(0)
    var startTransform = CGAffineTransformMakeRotation(0)
    var userIsInteracting = false

    // Calculated Properties
    var userIsNotInteracting: Bool {
        get {
            return !userIsInteracting
        }
        set(interacting) {
            userIsInteracting = !interacting
        }
    }
    
    var outsideCircle: Float {
        get {
            return Float(Float(container.bounds.height) * 2)
        }
    }
    
    var leafWidthAngle: Float {
        get {
            return Float(2) * Float(M_PI) / Float(numberOfSections)
        }
    }
    
    var numberOfSectionsIsEven: Bool {
        get {
            var numberOfSectionsIsEven: Bool
            if numberOfSections % 2 == 0 {
                numberOfSectionsIsEven = true
            } else {
                numberOfSectionsIsEven = false
            }
            return numberOfSectionsIsEven
        }
    }
    
    // Properties that hold closures. (a.k.a. a block based API)
    // These should be used as call backs alerting a view controller
    // that one of these events occurred.
    var wheelTurnedBackBy: wheelTurnedBackByDelegate = { leafCount, percentage in
        var plural = "leaves"
        if leafCount == 1 {
            plural = "leaf"
        }
        println("Wheel was turned back by \(leafCount) \(plural)")
    }

    
    
    // MARK: Initialization
    init(WithSections sectionsCount: Int) {
        super.init(frame: CGRect())

        numberOfSections = sectionsCount
        startTransform = CGAffineTransformMakeRotation(CGFloat(2.82743 + leafWidthAngle))
        drawWheel()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: Setup Methods
    func drawWheel() {
        
        // Build UIViews for each pie piece
        for i in 1...numberOfSections {
            var image = UIImage(named: imageNameFrom(i))
            
            let leafStartingAngle = CGFloat(M_PI * 3) + CGFloat(leafWidthAngle / 2)
            let leafAngle = (CGFloat(leafWidthAngle) * CGFloat(i)) - leafStartingAngle

            var imageView = UIImageView(image: image)
            imageView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.65)
            imageView.transform = CGAffineTransformMakeRotation(leafAngle)
            imageView.tag = i
            imageView.alpha = 0
            
            container.addSubview(imageView)
        }
        
        
        container.userInteractionEnabled = false
        self.addSubview(container)
        
        if numberOfSectionsIsEven {
            self.buildLeavesEven()
        } else {
            self.buildLeavesOdd()
        }
        
    }
    
    func paddedTwoDigitNumber(i: Int) -> String {
        var paddedTwoDigitNumber = "00"
        
        let numberFormater = NSNumberFormatter()
        numberFormater.minimumIntegerDigits  = 2
        numberFormater.maximumIntegerDigits  = 2
        numberFormater.minimumFractionDigits = 0
        numberFormater.maximumFractionDigits = 0
        
        if let numberString = numberFormater.stringFromNumber(i) {
            paddedTwoDigitNumber = numberString
        }
        return paddedTwoDigitNumber
    }
    
    func imageNameFrom(i: Int) -> String {
        return "Gavin Poses-s\(paddedTwoDigitNumber(i))"
    }
    
    func buildLeavesEven() {
        var mid = Float(M_PI) - (leafWidthAngle / 2)
        var max = Float(M_PI)
        var min = Float(M_PI) - leafWidthAngle
        
        for i in 1...numberOfSections {
            max = mid + (leafWidthAngle / 2)
            min = mid - (leafWidthAngle / 2)
            
            var leaf = ImageWheelLeaf(WithMin: min,
                AndMax: max,
                AndMid: mid,
                AndValue: i)
            
            mid -= leafWidthAngle
            
            leaves.append(leaf)
        }
    }
    
    
    func buildLeavesOdd() {
        var mid = Float(M_PI) - (leafWidthAngle / 2)
        var max = Float(M_PI)
        var min = Float(M_PI) - leafWidthAngle
        
        for i in 1...numberOfSections {
            max = mid + (leafWidthAngle / 2)
            min = mid - (leafWidthAngle / 2)
            
            var leaf = ImageWheelLeaf(WithMin: min,
                AndMax: max,
                AndMid: mid,
                AndValue: i)
            
            mid -= leafWidthAngle
            
            if (leaf.maxRadian < Float(-M_PI)) {
                mid = (mid * -1)
                mid -= leafWidthAngle
            }
            
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
                     constant: leafImageHeight))
    
                image.addConstraint( NSLayoutConstraint(item: image,
                    attribute: NSLayoutAttribute.Width,
                    relatedBy: NSLayoutRelation.Equal,
                       toItem: nil,
                    attribute: NSLayoutAttribute.NotAnAttribute,
                    multiplier: 1.0,
                     constant: leafImageWidth))
            }
        }
        
        rotateToAngle(CGFloat(leaves[0].midRadian + leafWidthAngle))
        getLeafImageByValue(1)?.alpha = 1
    }
    
    
    
    // MARK: UIControl methods handling the touches
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {

        if touchIsOffWheel(touch) {
            println("Ignoring tap: too close to the center or far off the wheel.")
            return false  // Ends current touches to the control
        }
        
        // Set state bigining user rotation
        userIsInteracting = true
        leafValueBeforeTouch = currentLeafValue
        deltaAngle = angleAtTouch(touch)
        startTransform = container.transform

        // Remember state during user rotation
        previousAngle = deltaAngle
        wheelHasFlipped360 = false
        return true
    }
    
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
        
        if touchIsOffWheel(touch) {
            println("drag path too close to the center or far off the wheel.");
            self.sendActionsForControlEvents(UIControlEvents.TouchDragExit)
            //self.sendActionsForControlEvents(UIControlEvents.TouchDragOutside)
            endTrackingWithTouch(touch, withEvent: event)
            return false  // Ends current touches to the control
        }
        
        let angle = angleAtTouch(touch)
        checkIfWheelHasFlipped360(angle)
        
        var angleDifference = (deltaAngle - angle)
        
        // Prevent the user from rotating to the left.
        var dampenRotation = false
        var angleDifferenceDamped = angleDifference
        var dampener = CGFloat(1.0)

        
        // The wheel is turned to the left when
        // angleDifference is positive.
        if angleDifference > 0 {
            dampenRotation = true
        }
        
        if wheelHasFlipped360 {
            dampenRotation = true
            angleDifference = (deltaAngle - angle) + CGFloat(M_PI * 2)
        }
        
        if dampenRotation {
            returnToPreviousLeaf = true
            let angleUntilDampended = CGFloat(leafWidthAngle * angleDifferenceDampenerFactor)
            dampener = CGFloat(1) - (angleDifference / angleUntilDampended)
            if dampener < 0.5 || wheelHasFlipped360 {
                dampener = 0.5
            }
            angleDifferenceDamped = angleDifference * dampener

        } else {
            returnToPreviousLeaf = false
        }
        
        // If the wheel rotates far enough, it will flip the 360 and
        // make it hard to track.  This makes the wheel jump and is
        // unclear to the user if the wheel was rotated to the
        // left or right.  Instead, we will just cancel the touch.
        let touchPoint = touchPointWithTouch(touch)
        var touchIsLowerThanCenterOfWheel = (touchPoint.y > container.center.y )

        if touchIsLowerThanCenterOfWheel {
            endTrackingWithTouch(touch, withEvent: event)
            return false  // Ends current touches to the control
        }
        
        container.transform = CGAffineTransformRotate(startTransform, -angleDifferenceDamped )
        self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
        self.sendActionsForControlEvents(UIControlEvents.TouchDragInside)

        // Remember state during user rotation
        previousAngle = angle

        return true
    }

    override func endTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) {

        // Clear state ending user rotation
        userIsNotInteracting = true
        
        let currentRotation = radiansFromTransform(container.transform)
        
        var currentLeafHasChanged = false
        
        for leaf in leaves {
            if (leaf.minRadian > 0.0 && leaf.maxRadian < 0.0) {
                println(" anomalous case ")
                if (leaf.maxRadian > currentRotation || leaf.minRadian < currentRotation) {
                    currentLeafHasChanged = setCurrentLeaf(leaf)
                }
            } else if (currentRotation > leaf.minRadian && currentRotation < leaf.maxRadian) {
                currentLeafHasChanged = setCurrentLeaf(leaf)
            }
            
            if currentLeafHasChanged {
                break
            }
        }
    
        
        
        // Animate the wheel to rest at one of the leaves.
        if returnToPreviousLeaf {
            animateToLeafByValue(leafValueBeforeTouch)
        } else {
            animateToLeafByValue(currentLeafValue)
        }
        
        if currentLeafHasChanged && !returnToPreviousLeaf {
            // Tell ViewController there was a change to the wheel leaf position
            var currentValue = currentLeafValue
            if currentValue > leafValueBeforeTouch {
                currentValue -= numberOfSections
            }
            let leafCount = leafValueBeforeTouch - currentValue
            
            let percentageStep = 1 / CGFloat((numberOfSections - 1))
            let percentage = percentageStep * CGFloat(leafCount)
            wheelTurnedBackBy(leafCount, AndPercentage: percentage)
        }

        
        // User rotation has ended.  Forget the state.
        previousAngle = nil
        wheelHasFlipped360 = false
        
        // NOTE: Possible Events to impliment (but some come free, so check)
        //self.sendActionsForControlEvents(UIControlEvents.TouchUpInside) // Comes for free
        //self.sendActionsForControlEvents(UIControlEvents.TouchUpOutside)
        //self.sendActionsForControlEvents(UIControlEvents.TouchCancel)
        
    }
    
    
    

    
    
    // MARK: Image Wheel Rotation Methods
    func rotateToLeafByValue(value: Int) {
        if let leaf = getLeafByValue(value) {
            rotateToLeaf(leaf)
        }
    }

    func rotateToLeaf(leaf: ImageWheelLeaf) {
        let angle = CGFloat(leaf.midRadian)
        rotateToAngle(angle)
        self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
        currentLeafValue = leaf.value;
        for i in 1...numberOfSections {
            if i == currentLeafValue {
                getLeafImageByValue(i)?.alpha = 1
            } else {
                getLeafImageByValue(i)?.alpha = 0
            }
        }
    }
    
    func rotateToAngle(angle: CGFloat) {
        let currentRotation = radiansFromTransform(container.transform)
        let newRotation = CGFloat(currentRotation) - angle

        if (userIsNotInteracting) {
            let t = CGAffineTransformRotate(container.transform, newRotation)
            container.transform = t;
            
        }
    }


    func animateToLeafByValue(value: Int) {
        if let leaf = getLeafByValue(value) {
            animateToLeaf(leaf)
        }
    }
    
    func animateToLeaf(leaf: ImageWheelLeaf) {
        let currentRotation = radiansFromTransform(container.transform)
        let newRotation = CGFloat(currentRotation) - CGFloat(leaf.midRadian)
        let radians = newRotation * -1
        if (userIsNotInteracting) {
            UIView.animateWithDuration(0.2,
                animations: {
                    let t = CGAffineTransformRotate(self.container.transform, radians)
                    self.container.transform = t;
                    for i in 1...self.numberOfSections {
                        if i == leaf.value {
                            self.getLeafImageByValue(i)?.alpha = 1
                        } else {
                            self.getLeafImageByValue(i)?.alpha = 0
                        }
                    }
                },
                completion: {
                    (value: Bool) in
                    self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
            })
        }
        
        self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
        
        currentLeafValue = leaf.value;
    }
    
    
    func animateImageWheelRotationByRadians(radians: CGFloat) {
        if (userIsNotInteracting) {
            UIView.animateWithDuration(0.2,
                animations: {
                    let t = CGAffineTransformRotate(self.container.transform, radians)
                    self.container.transform = t;
                    for i in 1...self.numberOfSections {
                        if i == self.currentLeafValue + 1 {
                            self.getLeafImageByValue(i)?.alpha = 1
                        } else {
                            self.getLeafImageByValue(i)?.alpha = 0
                        }
                    }
                },
                completion: {
                    (value: Bool) in
                    self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
                })
        }
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
    
    func setCurrentLeaf(leaf: ImageWheelLeaf) -> Bool {
        var currentLeafHasChanged = false
        if (currentLeafValue != leaf.value) {
            currentLeafValue = leaf.value
            currentLeafHasChanged = true
        }
        return currentLeafHasChanged
    }
    
    // MARK: Wheel touch and angles helper methods
    func touchPointWithTouch(touch: UITouch) -> CGPoint {
        return touch.locationInView(self)
    }
    
    func angleAtTouch(touch: UITouch) -> CGFloat {
        let touchPoint = touchPointWithTouch(touch)
        return angleAtTouchPoint(touchPoint)
    }
    
    func checkIfWheelHasFlipped360(angle: CGFloat) {
        if (previousAngle < -2) && (angle > 2) {
            wheelHasFlipped360 = true
        }
    }
    
    func angleAtTouchPoint(touchPoint: CGPoint) -> CGFloat {
        let dx = touchPoint.x - container.center.x
        let dy = touchPoint.y - container.center.y
        let angle = atan2(dy,dx)
        
        return angle
    }
    
    func touchIsOnWheel(touch: UITouch) -> Bool {
        let dist = distanceFromCenterWithTouch(touch)
        var touchIsOnWheel = true
        
        if (dist < centerCircle) {
            touchIsOnWheel = false
        }
        if (dist > outsideCircle) {
            touchIsOnWheel = false
        }
        return touchIsOnWheel
    }
    
    func touchIsOffWheel(touch: UITouch) -> Bool {
        return !touchIsOnWheel(touch)
    }
    
    func distanceFromCenterWithTouch(touch: UITouch) -> Float {
        let touchPoint = touchPointWithTouch(touch)
        return distanceFromCenterWithPoint(touchPoint)
    }
    
    func distanceFromCenterWithPoint(point: CGPoint) -> Float {
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

