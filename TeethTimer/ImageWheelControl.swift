import UIKit

typealias wheelTurnedBackByDelegate = (Int, AndPercentage: CGFloat) -> ()
typealias ImageIndex = Int

struct ImageWheelRotationKey {
    let timePercent: CGFloat
    let image: ImageIndex
}

enum DirectionToRotate {
    case Clockwise
    case CounterClockwise
    case Closest
}

enum DirectionRotated {
    case Clockwise
    case CounterClockwise
}

enum Parity {
    case Even
    case Odd
}

private let halfCircle = CGFloat(M_PI)
private let fullCircle = CGFloat(M_PI) * 2



class ImageWheelControl: UIControl, AnimationDelegate  {
    let centerCircle:                CGFloat =  20.0
    let wedgeImageHeight:            CGFloat = (800 * 0.9)
    let wedgeImageWidth:             CGFloat = (734 * 0.9)
    let rotationDampeningFactor:     CGFloat =  5.0
    let animateWedgeDuration: NSTimeInterval =  0.2
    
    var container = UIView()
    var numberOfWedges: Int = 0
    
    var wedges: [WedgeRegion] = []
    var images: [UIImage]     = []
    let userState   = ImageWheelInteractionState()
    let visualState = ImageWheelVisualState()
    
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
    
    var currentRotation: CGFloat {
        get {
            return radiansFromTransform(container.transform)
        }
    }
    
    var currentImage: ImageIndex {
        get {
            let wedgesCountForRotations = wedges.count * visualState.imageWheelFullRotations
            return currentWedgeValue + wedgesCountForRotations
        }
    }

    var currentWedge: WedgeRegion {
        get {
            return currentWedgeForAngle(currentRotation)
        }
    }
    
    var currentWedgeValue: WedgeValue {
        get {
            return currentWedge.value
        }
    }
    
    var outsideCircle: CGFloat {
        get {
            return container.bounds.height * 2
        }
    }
    
    var wedgeWidthAngle: CGFloat {
        get {
            return 2 * halfCircle / CGFloat(numberOfWedges)
        }
    }

    var wedgeCountParity: Parity {
        get {
            var result: Parity
            if numberOfWedges % 2 == 0 {
                result = .Even
            } else {
                result = .Odd
            }
            return result
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
    
    
    
    // MARK: -
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
        
        let wedgeStartingAngle = (halfCircle * 3) + CGFloat(self.wedgeWidthAngle / 2)
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
        
        if wedgeCountParity == .Even {
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
        var mid = halfCircle - (wedgeWidthAngle / 2)
        var max = halfCircle
        var min = halfCircle - wedgeWidthAngle
        
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
        var mid = halfCircle - (wedgeWidthAngle / 2)
        var max = halfCircle
        var min = halfCircle -  wedgeWidthAngle
        
        for i in 1...numberOfWedges {
            max = mid + (wedgeWidthAngle / 2)
            min = mid - (wedgeWidthAngle / 2)
            
            var wedge = WedgeRegion(WithMin: min,
                                     AndMax: max,
                                     AndMid: mid,
                                   AndValue: i)
            
            mid -= wedgeWidthAngle
            
            if (wedge.maxRadian < -halfCircle) {
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
        
        
        let firstWedge = wedgeFromValue(1)
        rotateToAngle(firstWedge.midRadian + wedgeWidthAngle)
        setImageOpacityForCurrentAngle(firstWedge.midRadian)
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
        userState.currently        = .Interacting
        userState.initialWedge     = currentWedgeValue
        userState.initialAngle     = angleAtTouch(touch)
        userState.previousAngle    = userState.initialAngle
        userState.initialTransform = container.transform
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
        checkIfRotatingClockwise(angle)
        
        // Prevent the user from rotating to the left.
        var angleDifference = userState.initialAngle - angle
        var dampenRotation  = false
        
        
        // The wheel is turned to the left when
        // angleDifference is positive.
        if userState.direction == .Clockwise {
            dampenRotation = true
        }
                                    
//        if currentWedgeValue > userState.wedgeValueBeforeTouch {
//            dampenRotation = true
//        }
        
        if userState.wheelHasFlipped360 {
            dampenRotation = true
            angleDifference = angleDifference + fullCircle
        }
        
        var angleDifferenceDamped = angleDifference
        if dampenRotation {
            angleDifferenceDamped = self.dampenRotation(angleDifference)
            userState.snapTo = .InitialWedge
        } else {
            userState.snapTo = .CurrentWedge
        }
                                    
        // If the wheel rotates far enough, it will flip the 360 and
        // make it hard to track.  This makes the wheel jump and is
        // unclear to the user if the wheel was rotated to the
        // left or right.  Instead, we will just cancel the touch.
        let touchPoint = touchPointWithTouch(touch)
        var touchIsLowerThanCenterOfWheel =  touchPoint.y > container.center.y
        
        if touchIsLowerThanCenterOfWheel {
            endTrackingWithTouch(touch, withEvent: event)
            return false  // Ends current touches to the control
        }
        
        container.transform = CGAffineTransformRotate( userState.initialTransform,
                                                       -angleDifferenceDamped )
                                    
        self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
        self.sendActionsForControlEvents(UIControlEvents.TouchDragInside)

        setImageOpacityForCurrentAngle(currentRotation)

        // Remember state during user rotation
        userState.previousAngle = angle
        
        return true
    }
    
    override func endTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) {
        
        // User interaction has ended, but most of the state is
        // still used through out this method.
        userState.currently = .NotInteracting
        
        // Animate the wheel to rest at one of the wedges.
        if userState.snapTo == .InitialWedge {
            animateToWedgeByValue(userState.initialWedge)
        } else {
            animateToWedgeByValue(currentWedge.value)
        }
        
        // Callback to block/closure based 'delegate' to
        // inform it that the wheel has been rewound.
        if userState.initialWedgeIsNotWedge(currentWedgeValue) &&
           userState.snapTo == .CurrentWedge {
            
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
    
    
    // MARK: -
    // MARK: Wedge Rotation Methods (Without Animating)
    func rotateToWedgeByValue(value: Int) {
        let wedge = wedgeFromValue(value)
        rotateToWedge(wedge)
    }
    
    func rotateToWedge(wedge: WedgeRegion) {
        rotateToAngle(wedge.midRadian)
    }
    
    func rotateToAngle(angle: CGFloat) {
        if (userState.currently == .NotInteracting) {
            let newRotation = currentRotation - angle
            let t = CGAffineTransformRotate(container.transform, newRotation)
            container.transform = t;
            setImageOpacityForCurrentAngle(angle)
        }
        self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
    }
    
    func wheelTurnedBack() {
        
        // TODO: Fix math and simplify
        // Callback to notify there was a change to the wheel wedge position
        var currentValue = currentWedgeValue
        if currentValue > userState.initialWedge {
            currentValue -= numberOfWedges
        }
        let wedgeCount = userState.initialWedge - currentValue
        
        let percentageStep = 1 / CGFloat((numberOfWedges - 1))
        let percentage = percentageStep * CGFloat(wedgeCount)
        println("turned back.  At % \(percentage)")
        
//        wheelTurnedBackBy(wedgeCount, AndPercentage: percentage)
    }
    
    // MARK: Wedge Animation Methods
    
    func animateToWedgeByValue(value: Int) {
        animateToWedgeByValue(value, inDirection: .Closest)
    }

    func animateToWedgeByValue(value: Int,
               inDirection direction: DirectionToRotate) {
        let wedge = wedgeFromValue(value)
        animateToWedge(wedge, inDirection: direction)
    }


    
    // TODO: remove method and other 'wedge' methods that are not needed after
    //       transitioning to 'image' methods
    func animateToWedge(wedge: WedgeRegion,
        inDirection direction: DirectionToRotate) {
        
        var currentWedge = self.currentWedge
        var steps: [ImageWheelRotationKey] = []
        let resolved = resolveDirectionAndCountToWedge( wedge,
                                           inDirection: direction)
            
        if resolved.count == 0 {
            let aStep = ImageWheelRotationKey(timePercent: 1.0,
                                                    image: currentWedge.value)
            steps.append(aStep)
            
        } else {
            let timeSlice = 1.0 / CGFloat(resolved.count)
            for i in 1...resolved.count {
                if resolved.direction == .Clockwise {
                    currentWedge = nextWedge(currentWedge)
                } else {
                    currentWedge = previousWedge(currentWedge)
                }
                
                
                let aStep = ImageWheelRotationKey(timePercent: timeSlice,
                                                        image: currentWedge.value)
                steps.append(aStep)
            }
        }

        animateToEachStep(steps)
    }
    

    func animateToEachStep(var steps: [ImageWheelRotationKey]) {

        // If there are no steps, then be done.
        // (and avoid the crashes that will come later 
        //  from the assumption we have steps to do)
        if steps.count == 0 { return }
        // TODO: change 2 to be greater when closer to iamges.count
        let duration = animateWedgeDuration * CFTimeInterval(steps.count) / 2
        
        let lastStep = steps.last!
        // Remove the last step, because this final step will be animated
        // in the completion block.
        steps.removeLast()
        
        
        var startTime = CFTimeInterval(0)
        var stepDuration = CFTimeInterval(0)
        for step in steps {
            let wedge = self.wedgeForImage(step.image)
            stepDuration = CFTimeInterval(step.timePercent * CGFloat(animateWedgeDuration))
            
            let imageStep = BasicAnimation(duration: CGFloat(stepDuration))
            imageStep.property = AnimatableProperty(name: kPOPLayerRotation)
            imageStep.toValue = wedge.midRadian
            imageStep.beginTime = startTime
            imageStep.name = "Image-\(step.image)"
            imageStep.delegate = self
            Animation.addAnimation(imageStep, key: imageStep.property.name, obj: self.container.layer)
            
            
            startTime = startTime + stepDuration
        }
    
        let wedge = wedgeForImage(lastStep.image)

        let lastImage = SpringAnimation(tension: 1000, friction: 30, mass: 1)
        lastImage.property = AnimatableProperty(name: kPOPLayerRotation)
        lastImage.toValue = wedge.midRadian
        lastImage.name = "LastRotation"
        lastImage.beginTime = startTime
        lastImage.delegate = self
//        lastImage.completionBlock = { anim, finsihed in
//            self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
//        }
        Animation.addAnimation(lastImage, key: lastImage.property.name, obj: self.container.layer)
    }
    
    func pop_animationDidApply(anim: POPAnimation!) {
        self.setImageOpacityForCurrentAngle(currentRotation)
        self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
    }
        
    
    func imageForWedge(             wedge: WedgeRegion,
         WhileCurrentImageIs currentImage: ImageIndex) -> ImageIndex {
            
        var currentWedge = wedgeForImage(currentImage)
        let resolved = resolveDirectionAndCountToWedge( wedge,
                                     GivenCurrentWedge: currentWedge,
                                           inDirection: .Closest)

        let image: ImageIndex
        if resolved.direction == .Clockwise {
            image = currentImage + resolved.count
        } else {
            image = currentImage - resolved.count
        }
            
        return image
    }
    
    func wedgeForImage(image: ImageIndex) -> WedgeRegion {
        var wedgeValue = image % wedges.count
        if wedgeValue == 0 {
            wedgeValue = wedges.count
        }
        return wedgeFromValue(wedgeValue)
    }
    
    // MARK: -
    // MARK: Rotation Methods (Without Animating)
    func rotateToImage(image: ImageIndex) {
        visualState.imageWheelFullRotations = image / wedges.count
        let wedge = wedgeForImage(image)
        rotateToWedge(wedge)
    }
    
    // MARK: Animation Methods
    func animateToImage(image: ImageIndex) {
        animateToImage( image, inDirection: .Closest)
    }
    
    
    func animateToImage(image: ImageIndex,
        inDirection direction: DirectionToRotate) {
            
            var steps: [ImageWheelRotationKey] = []
            let resolved = resolveDirectionAndCountToImage( image,
                inDirection: direction)
            var currentImage = self.currentImage
            
            
            if resolved.count == 0 {
                let aStep = ImageWheelRotationKey(timePercent: 1.0,
                    image: currentImage)
                steps.append(aStep)
                
            } else {
                let timeSlice = 1.0 / CGFloat(resolved.count)
                for i in 1...resolved.count {
                    if resolved.direction == .Clockwise {
                        currentImage = nextImage(currentImage)
                    } else {
                        currentImage = previousImage(currentImage)
                    }
                    
                    
                    let aStep = ImageWheelRotationKey(timePercent: timeSlice,
                        image: currentImage)
                    steps.append(aStep)
                }
            }
            
            animateToEachStep(steps)
    }
    
    func resolveDirectionAndCountToImage(image: ImageIndex,
                     var inDirection direction: DirectionToRotate)
                                 -> (direction: DirectionToRotate, count: Int) {
            
        let count: Int
        
        switch direction {
        case .Closest:
            let positiveCount = countFromImage( currentImage,
                ToImage: image,
                inDirection: .Clockwise)
            let negitiveCount = countFromImage( currentImage,
                ToImage: image,
                inDirection: .CounterClockwise)
            
            if positiveCount <= negitiveCount {
                count     = positiveCount
                direction = .Clockwise
            } else {
                count     = negitiveCount
                direction = .CounterClockwise
            }
            
        case .Clockwise:
            count = countFromImage( currentImage,
                ToImage: image,
                inDirection: .Clockwise)
            
        case .CounterClockwise:
            count = countFromImage( currentImage,
                ToImage: image,
                inDirection: .CounterClockwise)
            
        }
        
        return (direction, count)
            
    }
    
    func countFromImage( fromImage: ImageIndex,
        ToImage toImage: ImageIndex,
        inDirection direction: DirectionRotated) -> Int {
            
            var image = fromImage
            var count = 0
            while true {
                if image == toImage {
                    break
                }
                if direction == .Clockwise {
                    image = nextImage(image)
                } else {
                    image = previousImage(image)
                }
                ++count
            }
            return count
    }
    
    func nextImage(var image: ImageIndex) -> ImageIndex {
        ++image
        if image > images.count {
            image = 1
        }
        return image
    }
    
    func previousImage(var image: ImageIndex) -> ImageIndex {
        --image
        if image < 1 {
            image = images.count
        }
        return image
    }
    
    
    // MARK: -
    // MARK: Wedge Mothods
    func resolveDirectionAndCountToWedge(wedge: WedgeRegion,
                     var inDirection direction: DirectionToRotate)
                                 -> (direction: DirectionToRotate, count: Int) {
         return resolveDirectionAndCountToWedge( wedge,
                              GivenCurrentWedge: self.currentWedge,
                                    inDirection: direction)
    }
    
    func resolveDirectionAndCountToWedge(wedge: WedgeRegion,
                GivenCurrentWedge currentWedge: WedgeRegion,
                     var inDirection direction: DirectionToRotate)
                                 -> (direction: DirectionToRotate, count: Int) {
            
            let count: Int
            
            switch direction {
            case .Closest:
                let positiveCount = countFromWedgeValue( currentWedge.value,
                                           ToWedgeValue: wedge.value,
                                            inDirection: .Clockwise)
                let negitiveCount = countFromWedgeValue( currentWedge.value,
                                           ToWedgeValue: wedge.value,
                                            inDirection: .CounterClockwise)
                
                if positiveCount <= negitiveCount {
                    count     = positiveCount
                    direction = .Clockwise
                } else {
                    count     = negitiveCount
                    direction = .CounterClockwise
                }
                
            case .Clockwise:
                count = countFromWedgeValue( currentWedge.value,
                               ToWedgeValue: wedge.value,
                                inDirection: .Clockwise)
                
            case .CounterClockwise:
                count = countFromWedgeValue( currentWedge.value,
                               ToWedgeValue: wedge.value,
                                inDirection: .CounterClockwise)
            }
            
            return (direction, count)
            
    }

    func countFromWedgeValue( fromValue: Int,
                 ToWedgeValue toValue: Int,
       inDirection direction: DirectionRotated) -> Int {
        
        var value = fromValue
        var count = 0
        while true {
            if value == toValue {
                break
            }
            if direction == .Clockwise {
                value = nextWedgeValue(value)
            } else {
                value = previousWedgeValue(value)
            }
            ++count
        }
        return count
    }
    
    func nextWedge(wedge: WedgeRegion) -> WedgeRegion {
        let value = nextWedgeValue(wedge.value)
        return wedgeFromValue(value)
    }
    
    func previousWedge(wedge: WedgeRegion) -> WedgeRegion {
        let value = previousWedgeValue(wedge.value)
        return wedgeFromValue(value)
    }
    
    func nextWedgeValue(var value: Int) -> Int {
        ++value
        if value > wedges.count {
            value = 1
        }
        return value
    }
    
    func previousWedgeValue(var value: Int) -> Int {
        --value
        if value < 1 {
            value = wedges.count
        }
        return value
    }
    
    
    func wedgeFromValue(value: Int) -> WedgeRegion {
        
        var returnWedge: WedgeRegion?
        
        for wedge in wedges {
            if wedge.value == value {
                returnWedge = wedge
            }
        }
        
        assert(returnWedge != nil, "wedgeFromValue():  No wedge found with value \(value)")
        return returnWedge!
    }

    
    func currentWedgeForAngle(var angle: CGFloat) -> WedgeRegion {
        
        angle = normalizedAngleForAngle(angle)
        
        // Determin where the wheel is (which wedge we are within)
        var currentWedge: WedgeRegion?
        for wedge in wedges {
            if currentRotation(angle, isWithinWedge: wedge) {
                currentWedge = wedge
                break
            }
        }
        assert(currentWedge != nil,"currentWedgeForAngle() may not be nil. Wedges do not fill the circle.")
        return currentWedge!
    }
    
    func setImageOpacityForCurrentAngle(var angle: CGFloat) {
        visualState.initOpacityListWithWedges(wedges)

        // Shift the rotation 1/2 a wedge width angle
        // This is to center the effect of changing the opacity.
        angle = angle + (wedgeWidthAngle / 2)
        angle = normalizedAngleForAngle(angle)
        
        for wedge in wedges {
            
            if angle >= wedge.minRadian &&
               angle <=  wedge.maxRadian    {
                
                let percent = percentValue( angle,
                              isBetweenLow: wedge.minRadian,
                                   AndHigh: wedge.maxRadian)
                
                visualState.wedgeOpacityList[wedge.value]    = percent
                    
                    
                let neighbor = neighboringWedge(wedge)
                let invertedPercent = 1 - percent
                visualState.wedgeOpacityList[neighbor.value] = invertedPercent
                    
            }
        }
//        let ten = visualState.wedgeOpacityList[10]!
//        let one = visualState.wedgeOpacityList[1]!
//        
//        println("10: \(pad(ten))    01:\(pad(one))   angle: \(pad(angle))")
        visualState.setOpacityOfWedgeImageViews(allWedgeImageViews)
    }
    
    
    func neighboringWedge(wedge: WedgeRegion) -> WedgeRegion {
        var wedgeValue = wedge.value
        if wedgeValue == wedges.count {
            wedgeValue = 1
        } else {
            ++wedgeValue
        }
        
        let otherWedge = wedgeFromValue(wedgeValue)
        return otherWedge
    }
    
    
    func currentRotation(currentRotation: CGFloat,
                     isWithinWedge wedge: WedgeRegion) -> Bool {
        var withinWedge = false
        
        if (currentRotation >= wedge.minRadian &&
            currentRotation <= wedge.maxRadian   ) {
                withinWedge = true
        }
        
        return withinWedge
    }
    
    func normalizedAngleForAngle(var angle: CGFloat) -> CGFloat {
        let positiveHalfCircle =  halfCircle
        let negitiveHalfCircle = -halfCircle
        
        while angle > positiveHalfCircle || angle < negitiveHalfCircle {
            if angle > positiveHalfCircle {
                angle -= fullCircle
            }
            if angle < negitiveHalfCircle {
                angle += fullCircle
            }
        }
        return angle
    }
    
    
    
    
    
    
    
   // MARK: -
   // MARK: Whole Wheel Helpers
    func checkIfWheelHasFlipped360(angle: CGFloat) {
        // TODO: This is janky.  Is there bettter math???
        if (userState.previousAngle < -2) && (angle > 2) {
            userState.wheelHasFlipped360 = true
        }
    }
    
    func checkIfRotatingClockwise(angle: CGFloat) {
        let angleDifference = userState.initialAngle - angle
        if angleDifference > 0 {
            userState.direction = .Clockwise
        } else {
            userState.direction = .CounterClockwise
        }
    }

    
    // MARK: UITouch Helpers
    func touchPointWithTouch(touch: UITouch) -> CGPoint {
        return touch.locationInView(self)
    }
    
    func angleAtTouch(touch: UITouch) -> CGFloat {
        let touchPoint = touchPointWithTouch(touch)
        return angleAtTouchPoint(touchPoint)
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
    
    func distanceFromCenterWithTouch(touch: UITouch) -> CGFloat {
        let touchPoint = touchPointWithTouch(touch)
        return distanceFromCenterWithPoint(touchPoint)
    }
    
    func distanceFromCenterWithPoint(point: CGPoint) -> CGFloat {
        let center = CGPointMake(self.bounds.size.width  / 2.0,
            self.bounds.size.height / 2.0)
        
        return distanceBetweenPointA(center, AndPointB: point)
    }
    
    func distanceBetweenPointA(pointA: CGPoint,
                     AndPointB pointB: CGPoint) -> CGFloat {
        let dx = pointA.x - pointB.x
        let dy = pointA.y - pointB.y
        let sqrtOf = dx * dx + dy * dy
        
        return sqrt(sqrtOf)
    }

    // MARK: Angle Helpers
    func radiansFromTransform(transform: CGAffineTransform) -> CGFloat {
        let b = transform.b
        let a = transform.a
        let radians = atan2(b, a)
        
        return radians
    }
    
    func dampenRotation(angle: CGFloat) -> CGFloat {
        return (log((angle * rotationDampeningFactor) + 1) / rotationDampeningFactor)
    }
    
    // MARK: Math Helpers
    func percentValue(value: CGFloat,
        isBetweenLow   low: CGFloat,
        AndHigh       high: CGFloat ) -> CGFloat {
            return (value - low) / (high - low)
    }
    
    // MARK: Debug printing methods
    func padd(number: CGFloat) -> String {
        var paddedNumber = " 1.000"
        if let numberString = padNumber.stringFromNumber(number) {
            paddedNumber = numberString
        }
        return paddedNumber
    }
    
    func pad(number: CGFloat) -> String {
        var paddedNumber = " 1.000"
        if let numberString = padNumber.stringFromNumber(number) {
            paddedNumber = numberString
        }
        return paddedNumber
    }
    
    // MARK: Other
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
    
    func imageOfNumber(i: Int) -> UIImage {
        return images[i - 1]
    }

}

