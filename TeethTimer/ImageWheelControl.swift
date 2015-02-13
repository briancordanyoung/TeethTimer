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
    
    let centerCircle:              Float =  20.0
    let wedgeImageHeight:        CGFloat = (800 * 0.9)
    let wedgeImageWidth:         CGFloat = (734 * 0.9)
    let rotationDampeningFactor: CGFloat =  5.0
    
    var container = UIView()
    var numberOfWedges = 6
    var wedges: [WedgeRegion] = []
    var images: [UIImage] = []

    var allWedgeImageViews: [UIImageView] {
        get {
            let views = container.subviews
            
            var wedgeImageViews: [UIImageView] = []
            for image in views {
                if image.isKindOfClass(UIImageView.self) {
                    let imageView = image as! UIImageView
                    if imageView.tag != 0 {
                        wedgeImageViews.append(imageView)
                    }
                }
            }
            return wedgeImageViews
        }
    }
    
    
    var currentWedgeValue = 1         // wedge to image?
    let userState = ImageWheelInteractionState()
    
    var outsideCircle: Float {
        get {
            return Float(Float(container.bounds.height) * 2)
        }
    }
    
    var wedgeWidthAngle: Float {
        get {
            return Float(2) * Float(M_PI) / Float(numberOfWedges)
        }
    }

    var numberOfWedgesAreEven: Bool {
        get {
            var numberOfWedgesAreEven: Bool
            if numberOfWedges % 2 == 0 {
                numberOfWedgesAreEven = true
            } else {
                numberOfWedgesAreEven = false
            }
            return numberOfWedgesAreEven
        }
    }
    
    lazy var padNumber: NSNumberFormatter = {
        let numberFormater = NSNumberFormatter()
        numberFormater.minimumIntegerDigits  = 1
        numberFormater.maximumIntegerDigits  = 1
        numberFormater.minimumFractionDigits = 3
        numberFormater.maximumFractionDigits = 3
        numberFormater.positivePrefix = " "
        return numberFormater
    }()
    
    // Properties that hold closures. (a.k.a. a block based API)
    // These should be used as call backs alerting a view controller
    // that one of these events occurred.
    var wheelTurnedBackBy: wheelTurnedBackByDelegate = { wedgeCount, percentage in
        var plural = "wedges"
        if wedgeCount == 1 {
            plural = "wedge"
        }
        println("Wheel was turned back by \(wedgeCount) \(plural)")
    }
    
    
    
    // MARK: Initialization
    init(WithSections sectionsCount: Int, AndImages images: [UIImage]) {
        super.init(frame: CGRect())
        
        self.images = images
        numberOfWedges = sectionsCount
        createWedges()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Setup Methods
    func createWedges() {
        
        let wedgeStartingAngle = CGFloat(M_PI * 3) + CGFloat(self.wedgeWidthAngle / 2)
        // Build UIViews for each pie piece
        for i in 1...numberOfWedges {
            
            let wedgeAngle = (CGFloat(wedgeWidthAngle) * CGFloat(i)) - wedgeStartingAngle
            
            var imageView = UIImageView(image: imageOfNumber(i))
            imageView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.65)
            imageView.transform = CGAffineTransformMakeRotation(wedgeAngle)
            imageView.tag = i
            
            container.addSubview(imageView)
        }
        
        
        container.userInteractionEnabled = false
        self.addSubview(container)
        
        if numberOfWedgesAreEven {
            createWedgeRegionsEven()
        } else {
            createWedgeRegionsOdd()
        }
        
    }
    
    func createWedgeAtIndex(i: Int, AndAngle angle: CGFloat) -> UIImageView {
        var imageView = UIImageView()
        imageView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.65)
        imageView.transform = CGAffineTransformMakeRotation(angle)
        imageView.tag = i
        return imageView
    }
    
    func createWedgeRegionsEven() {
        var mid = Float(M_PI) - (wedgeWidthAngle / 2)
        var max = Float(M_PI)
        var min = Float(M_PI) - wedgeWidthAngle
        
        for i in 1...numberOfWedges {
            max = mid + (wedgeWidthAngle / 2)
            min = mid - (wedgeWidthAngle / 2)
            
            var wedge = WedgeRegion(WithMin: min,
                AndMax: max,
                AndMid: mid,
                AndValue: i)
            
            mid -= wedgeWidthAngle
            
            wedges.append(wedge)
        }
    }
    
    
    func createWedgeRegionsOdd() {
        var mid = Float(M_PI) - (wedgeWidthAngle / 2)
        var max = Float(M_PI)
        var min = Float(M_PI) - wedgeWidthAngle
        
        for i in 1...numberOfWedges {
            max = mid + (wedgeWidthAngle / 2)
            min = mid - (wedgeWidthAngle / 2)
            
            var wedge = WedgeRegion(WithMin: min,
                AndMax: max,
                AndMid: mid,
                AndValue: i)
            
            mid -= wedgeWidthAngle
            
            if (wedge.maxRadian < Float(-M_PI)) {
                mid = (mid * -1)
                mid -= wedgeWidthAngle
            }
            
            wedges.append(wedge)
        }
    }
    
    
    // MARK: Constraint setup
    func addConstraintsToViews() {
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        container.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        // constraints
        let viewsDictionary = ["controlView":container]
        
        //position constraints
        let view_constraint_H:[AnyObject] =
            NSLayoutConstraint.constraintsWithVisualFormat("H:|[controlView]|",
                                            options: NSLayoutFormatOptions(0),
                                            metrics: nil,
                                              views: viewsDictionary)
        
        let view_constraint_V:[AnyObject] =
            NSLayoutConstraint.constraintsWithVisualFormat("V:|[controlView]|",
                                            options: NSLayoutFormatOptions(0),
                                            metrics: nil,
                                              views: viewsDictionary)
        
        self.addConstraints(view_constraint_H)
        self.addConstraints(view_constraint_V)
        
        for i in 1...numberOfWedges {
            if let imageView = wedgeImageViewFromValue(i) {
                
                imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
                
                container.addConstraint(NSLayoutConstraint(item: imageView,
                    attribute: NSLayoutAttribute.CenterY,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: container,
                    attribute: NSLayoutAttribute.CenterY,
                    multiplier: 1.0,
                    constant: 0.0))
                
                container.addConstraint(NSLayoutConstraint(item: imageView,
                    attribute: NSLayoutAttribute.CenterX,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: container,
                    attribute: NSLayoutAttribute.CenterX,
                    multiplier: 1.0,
                    constant: 0.0))
                
                imageView.addConstraint( NSLayoutConstraint(item: imageView,
                    attribute: NSLayoutAttribute.Height,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: nil,
                    attribute: NSLayoutAttribute.NotAnAttribute,
                    multiplier: 1.0,
                    constant: wedgeImageHeight))
                
                imageView.addConstraint( NSLayoutConstraint(item: imageView,
                    attribute: NSLayoutAttribute.Width,
                    relatedBy: NSLayoutRelation.Equal,
                    toItem: nil,
                    attribute: NSLayoutAttribute.NotAnAttribute,
                    multiplier: 1.0,
                    constant: wedgeImageWidth))
            }
        }
        
        rotateToAngle(CGFloat(wedges[0].midRadian + wedgeWidthAngle))
        
        if let firstWedge = wedgeFromValue(1) {
            setImageOpacityForCurrentWedge(firstWedge)
        }
    }
    
    
    
    // MARK: UIControl methods handling the touches
    override func beginTrackingWithTouch(touch: UITouch,
                               withEvent event: UIEvent) -> Bool {
        userState.reset()
                                        
        if touchIsOffWheel(touch) {
            println("Ignoring tap: too close to the center or far off the wheel.")
            return false  // Ends current touches to the control
        }
        
        // Set state at the beginning of the users rotation
        userState.isInteracting         = true
        userState.wedgeValueBeforeTouch = currentWedgeValue
        userState.firstTouchAngle       = angleAtTouch(touch)
        userState.startTransform        = container.transform
        
        // Remember state during user rotation
        userState.previousAngle         = userState.firstTouchAngle
        userState.wheelHasFlipped360    = false
        return true
    }
    
    override func continueTrackingWithTouch(touch: UITouch,
                                  withEvent event: UIEvent) -> Bool {
        
        if touchIsOffWheel(touch) {
            println("drag path too close to the center or far off the wheel.");
            self.sendActionsForControlEvents(UIControlEvents.TouchDragExit)
            //self.sendActionsForControlEvents(UIControlEvents.TouchDragOutside)
            endTrackingWithTouch(touch, withEvent: event)
            return false  // Ends current touches to the control
        }
        
        let angle = angleAtTouch(touch)
        checkIfWheelHasFlipped360(angle)
        checkIfRotatingPositive(angle)
        
        // Prevent the user from rotating to the left.
        var angleDifference = (userState.firstTouchAngle - angle)
        var dampenRotation  = false
        
        
        // The wheel is turned to the left when
        // angleDifference is positive.
        if userState.rotatedPositive {
            dampenRotation = true
        }
        
        if userState.wheelHasFlipped360 {
            dampenRotation = true
            angleDifference = angleDifference + CGFloat(M_PI * 2)
        }
        
        var angleDifferenceDamped = angleDifference
        if dampenRotation {
            angleDifferenceDamped = self.dampenRotation(angleDifference)
            userState.returnToPreviousWedge = true
        } else {
            userState.returnToPreviousWedge = false
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
        
        container.transform = CGAffineTransformRotate( userState.startTransform,
                                                       -angleDifferenceDamped )
        self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
        self.sendActionsForControlEvents(UIControlEvents.TouchDragInside)

        let currentRotation = radiansFromTransform(container.transform)
        setImageOpacityForCurrentAngle(Float(currentRotation))

                                    
        // Remember state during user rotation
        userState.previousAngle = angle
        
        return true
    }
    
    override func endTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) {
        
        // User interaction has ended, but most of the state is
        // still used through out this method.
        userState.isNotInteracting = true
        
        // Animate the wheel to rest at one of the wedges.
        if userState.returnToPreviousWedge {
            animateToWedgeByValue(userState.wedgeValueBeforeTouch)
        } else {
            animateToWedgeByValue(currentWedgeValue)
        }
        
        let currentWedgeHasChanged = checkWedgeAndChangeCurrentValueIfNeeded()
        
        // Callback to block/closure based 'delegate' to
        // inform it that the wheel has been rewound.
        if currentWedgeHasChanged && userState.dontReturnToPreviousWedge {
            wheelTurnedBack()
        }
        
        // User rotation has ended.  Forget the state.
        userState.reset()
        
        comments(){
            /*
            NOTE: Possible Events to impliment (but some come free, so check)
            self.sendActionsForControlEvents(UIControlEvents.TouchUpInside)  Comes for free
            self.sendActionsForControlEvents(UIControlEvents.TouchUpOutside)
            self.sendActionsForControlEvents(UIControlEvents.TouchCancel)
            */
        }
    }
    
    
    
    

    
    // MARK: Image Wheel Rotation Methods
    // TODO: rotateToImageNumber
    // func rotateToImageNumber(i: Int)
    func rotateToWedgeByValue(value: Int) {
        if let wedge = wedgeFromValue(value) {
            rotateToWedge(wedge)
        }
    }
    
    func rotateToWedge(wedge: WedgeRegion) {
        let angle = CGFloat(wedge.midRadian)
        rotateToAngle(angle)
        setImageOpacityForCurrentWedge(wedge)
    }
    
    func rotateToAngle(angle: CGFloat) {
        let currentRotation = radiansFromTransform(container.transform)
        let newRotation = CGFloat(currentRotation) - angle
        
        if (userState.isNotInteracting) {
            let t = CGAffineTransformRotate(container.transform, newRotation)
            container.transform = t;
        }
        self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
    }
    
    func wheelTurnedBack() {
        // Callback to notify there was a change to the wheel wedge position
        var currentValue = currentWedgeValue
        if currentValue > userState.wedgeValueBeforeTouch {
            currentValue -= numberOfWedges
        }
        let wedgeCount = userState.wedgeValueBeforeTouch - currentValue
        
        let percentageStep = 1 / CGFloat((numberOfWedges - 1))
        let percentage = percentageStep * CGFloat(wedgeCount)
        wheelTurnedBackBy(wedgeCount, AndPercentage: percentage)
    }
    
    // TODO: animateToImageNumber
    // func animateToImageNumber(i: Int)
    func animateToWedgeByValue(value: Int) {
        if let wedge = wedgeFromValue(value) {
            animateToWedge(wedge)
        }
    }
    
    // TODO: animateToImageNumber
    func animateToWedge(wedge: WedgeRegion) {
        let currentRotation = radiansFromTransform(container.transform)
        let newRotation = CGFloat(currentRotation) - CGFloat(wedge.midRadian)
        let radians = newRotation * -1

        if (userState.isNotInteracting) {
            UIView.animateWithDuration(0.2,
                animations: {
                    let t = CGAffineTransformRotate(self.container.transform, radians)
                    self.container.transform = t;
                    self.setImageOpacityForCurrentWedge(wedge)
                },
                completion: {
                    (value: Bool) in
                    self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
            })
        }
        
        currentWedgeValue = wedge.value;
    }

    
    
    
    
    func wedgeImageViewFromValue(value: Int) -> UIImageView? {
        
        var wedgeView: UIImageView?
        
        for image in allWedgeImageViews {
            let imageView = image as UIImageView
            if imageView.tag == value {
                wedgeView = imageView
            }
        }
        
        return wedgeView
    }
    
    func wedgeFromValue(value: Int) -> WedgeRegion? {
        
        var returnWedge: WedgeRegion?
        
        for wedge in wedges {
            if wedge.value == value {
                returnWedge = wedge
            }
        }
        
        return returnWedge
    }

    
    func currentWedgeForAngle(angle: Float) -> WedgeRegion {
        var currentWedge: WedgeRegion?
        // Determin where the wheel is (which wedge we are within)
        for wedge in wedges {
            if currentRotation(angle, isWithinWedge: wedge) {
                currentWedge = wedge
                break
            }
        }
        assert(currentWedge != nil,"currentWedgeForAngle() may not be nil. Wedges do not fill the circle.")
        return currentWedge!
    }
    
    
    func checkWedgeAndChangeCurrentValueIfNeeded() -> Bool {
        let currentRotation = radiansFromTransform(container.transform)
        let wedgeValue = currentWedgeForAngle(currentRotation).value
        
        var currentWedgeHasChanged = false
        if wedgeValue != currentWedgeValue {
            currentWedgeHasChanged = true
            currentWedgeValue = wedgeValue
        }
        return currentWedgeHasChanged
    }
    
    func setImageOpacityForCurrentWedge(wedge: WedgeRegion) {
        currentWedgeValue = wedge.value;
        for i in 1...numberOfWedges {
            if i == currentWedgeValue {
                wedgeImageViewFromValue(i)?.alpha = 1
            } else {
                wedgeImageViewFromValue(i)?.alpha = 0
            }
        }
    }
    
    func setImageOpacityForCurrentAngle(currentAngle: Float) {
        userState.initOpacityListWithWedges(wedges)
        
        // Shift the rotation 1/2 a wedge width angle to center the effect
        // of changing the opacity.
        var angle = currentAngle + (wedgeWidthAngle / 2)
        if angle > Float(M_PI) {
            angle = angle - Float(M_PI * 2)
        }
        
        for wedge in wedges {
            
            if angle > wedge.minRadian &&
                angle < wedge.maxRadian    {
                    
                    let neighbor = neighboringWedge(wedge)
                    
                    let percent = percentValue( angle,
                        isBetweenLow: wedge.minRadian,
                        AndHigh: wedge.maxRadian)
                    let invertedPrecent = 1 - percent
                    
                    userState.wedgeOpacityList[wedge.value]    = CGFloat(percent)
                    userState.wedgeOpacityList[neighbor.value] = CGFloat(invertedPrecent)
            }
        }
        
        userState.setOpacityOfWedgeImageViews(allWedgeImageViews)
    }
    
    func percentValue(value: Float,
         isBetweenLow   low: Float,
         AndHigh       high: Float ) -> Float {
        return (value - low) / (high - low)
    }
    
    
    func neighboringWedge(wedge: WedgeRegion) -> WedgeRegion {
        var wedgeValue = wedge.value
        if wedgeValue == wedges.count {
            wedgeValue = 1
        } else {
            wedgeValue = wedgeValue + 1
        }
        
        let otherWedge = wedgeFromValue(wedgeValue)
        assert(otherWedge != nil, "otherWedge may not be nil.  No wedge found with value \(wedgeValue)")
        
        return otherWedge!
    }
    
    
    func setCurrentWedge(wedge: WedgeRegion) -> Bool {
        var currentWedgeHasChanged = false
        if (currentWedgeValue != wedge.value) {
            currentWedgeValue = wedge.value
            currentWedgeHasChanged = true
        }
        return currentWedgeHasChanged
    }
    
    func imageOfNumber(i: Int) -> UIImage {
        return images[i - 1]
    }
    
    
    
    // MARK: Wheel touch and angle helper methods
    func currentRotation(currentRotation: Float,
                       isWithinWedge wedge: WedgeRegion) -> Bool {
        var withinWedge = false
        
        if (currentRotation > wedge.minRadian &&
            currentRotation < wedge.maxRadian   ) {
                withinWedge = true
        }
        
        return withinWedge
    }
    
    
    func touchPointWithTouch(touch: UITouch) -> CGPoint {
        return touch.locationInView(self)
    }
    
    func angleAtTouch(touch: UITouch) -> CGFloat {
        let touchPoint = touchPointWithTouch(touch)
        return angleAtTouchPoint(touchPoint)
    }
    
    func checkIfWheelHasFlipped360(angle: CGFloat) {
        if (userState.previousAngle < -2) && (angle > 2) {
            userState.wheelHasFlipped360 = true
        }
    }
    
    func checkIfRotatingPositive(angle: CGFloat) {
        let angleDifference = userState.firstTouchAngle - angle
        if angleDifference > 0 {
            userState.rotatedPositive = true
        } else {
            userState.rotatedNegitive = true
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
    
    func distanceBetweenPointA(pointA: CGPoint,
                     AndPointB pointB: CGPoint) -> Float {
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
    
    
    func pad(number: CGFloat) -> String {
        var paddedNumber = " 1.000"
        if let numberString = padNumber.stringFromNumber(number) {
            paddedNumber = numberString
        }
        return paddedNumber
    }
    
    func dampenRotation(angle: CGFloat) -> CGFloat {
        return (log((angle * rotationDampeningFactor) + 1) / rotationDampeningFactor)
    }

}

