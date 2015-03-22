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

let halfCircle = CGFloat(M_PI)
let fullCircle = CGFloat(M_PI) * 2



class ImageWheelControl: UIControl, AnimationDelegate  {
    let centerCircle:                CGFloat =  20.0
    let wedgeImageHeight:            CGFloat = (800 * 0.9)
    let wedgeImageWidth:             CGFloat = (734 * 0.9)
    let rotationDampeningFactor:     CGFloat =  5.0
    var images: [UIImage]     = []
    
    var container = UIView()
    var numberOfWedges: Int = 0
    
    var wedges: [WedgeRegion] = []
    var wheelAnimations: [String:BasicAnimation] = [:]
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
    
    var currentAngle: CGFloat {
        get {
            return radiansFromTransform(container.transform)
        }
    }
    var currentRotation: CGFloat = 0.0
    
    var currentImage: ImageIndex {
        get {
            func near(x: CGFloat) -> CGFloat { return round(x * 4) }
            
            var image    = currentWedgeValue
            
            var rotation = currentRotation
            let angle    = currentAngle

            while near(rotation) != near(angle) {
                
                if near(rotation) > near(angle) {
                    for i in 1...numberOfWedges {
                        image = previousImage(image)
                    }
                    rotation -= fullCircle
                }
                
                if near(rotation) < near(angle) {
                    for i in 1...numberOfWedges {
                        image = nextImage(image)
                    }
                    rotation += fullCircle
                }
            }
            
            return image
        }
    }

    var firstImageRotation: CGFloat {
        get {
            return wedgeFromValue(1).midRadian
        }
    }
    
    var lastImageRotation: CGFloat {
        get {
            let rotationAmountFromFristToLast = wedgeWidthAngle * CGFloat(images.count)
            return firstImageRotation - rotationAmountFromFristToLast
        }
    }
    
    var currentWedge: WedgeRegion {
        get {
            return wedgeForAngle(currentAngle)
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
            return fullCircle / CGFloat(numberOfWedges)
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
    
    // TODO: Remove after main development
    lazy var padNumber: NSNumberFormatter = {
        let numberFormater = NSNumberFormatter()
        numberFormater.minimumIntegerDigits  = 2
        numberFormater.maximumIntegerDigits  = 2
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
        
        
        resetWheel()
    }
    
    // MARK: Return to known state
    func resetWheel() {
        let angle = wedgeFromValue(1).midRadian
        container.transform = CGAffineTransformMakeRotation(angle)
        currentRotation = currentAngle
        setImageOpacityForCurrentAngle(currentAngle)
        
        println("F:        T:        A:\(pad(currentAngle)) R:\(pad(currentRotation))")
        
    }
    
    
    // MARK: -
    // MARK: UIControl methods handling the touches
    override func beginTrackingWithTouch(touch: UITouch,
                               withEvent event: UIEvent) -> Bool {
        userState.reset()

        if touchIsOffWheel(touch) {
            println("Ignoring tap: too close to the center or far off the wheel.")
            return false  // Ends current touches to the control
        }
        
        // TODO: Handle Touches during animation
        // Pause POPAnimation & Timer
                                
        // Set state at the beginning of the users rotation
        userState.currently          = .Interacting
        userState.initialTransform   = container.transform
        userState.initialImage       = currentImage
        userState.initialRotation    = currentRotation
        userState.initialTouchAngle  = angleAtTouch(touch)
        userState.previousTouchAngle = userState.initialTouchAngle
                                
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
        
        let touchAngle = angleAtTouch(touch)
                                    
        // Prevent the user from rotating CounterClockwise.
        let angleDifference = userState.initialTouchAngle - touchAngle
        var angleDifferenceDamped = angleDifference
        var dampenRotation  = false
        userState.snapTo = .CurrentImage
        
        if currentRotation < userState.initialRotation {
            dampenRotation = true
            userState.snapTo = .InitialImage
        }
                                    
//        if currentRotation < firstImageRotation {
//            dampenRotation = true
//        }
//
//        if currentRotation > lastImageRotation {
//            dampenRotation = true
//        }
                                    
        if dampenRotation {
            angleDifferenceDamped = dampenRotationAngle(angleDifference)
        }
                                    
                           
        // If the wheel rotates far enough, it will flip the 360 and
        // make it hard to track.  This makes the wheel jump and is
        // unclear to the user if the wheel was rotated to the
        // left or right.  Instead, we will just cancel the touch.
        let touchPoint = touchPointWithTouch(touch)
        var touchIsLowerThanCenterOfWheel =  touchPoint.y > container.center.y
        var touchIsLeftThanCenterOfWheel  =  touchPoint.x < container.center.x
        
        var newRotation = userState.initialRotation + -angleDifferenceDamped
        if touchIsLowerThanCenterOfWheel && touchIsLeftThanCenterOfWheel {
              newRotation -= fullCircle
        }
        
        container.transform = CGAffineTransformRotate( userState.initialTransform,
                                                       -angleDifferenceDamped )
        currentRotation = newRotation

        if angleDifferenceDamped.isNaN || newRotation.isNaN || currentAngle.isNaN {
            
        }
                                    
        self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
        self.sendActionsForControlEvents(UIControlEvents.TouchDragInside)
        
        if currentRotation > userState.initialRotation {
            wheelRotatedTo(currentAngle, turningDirection: .CounterClockwise)
        } else {
            wheelRotatedTo(currentAngle, turningDirection: .Clockwise)
        }
        
        println("F:        T:        A:\(pad(currentAngle)) R:\(pad(currentRotation))")

        userState.previousTouchAngle = touchAngle
        return true
    }
    
    override func endTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) {
        
        // User interaction has ended, but most of the state is
        // still used through out this method.
        userState.currently = .NotInteracting

        if currentRotation > firstImageRotation {
            userState.snapTo = .FirstImage
        }
        if currentRotation < lastImageRotation {
            userState.snapTo = .LastImage
        }
        
        
        // Animate the wheel to rest at one of the wedges.
        switch userState.snapTo {
            case .InitialImage:
                animateToImage(userState.initialImage)
            case .CurrentImage:
                animateToImage(currentImage)
            case .FirstImage:
                animateToImage(1)
            case .LastImage:
                animateToImage(images.count)
        }
        
        
        // Callback to block/closure based 'delegate' to
        // inform it that the wheel has been rewound.
        if currentImage      != userState.initialImage &&
           userState.snapTo  != .CurrentImage {
                wheelWasTurnedBack()
        }
        
        // User rotation has ended.  Forget the state.
        userState.reset()
        
        comments(){
            /*
            TODO: Possible Events to impliment (but some come free, so check)
            self.sendActionsForControlEvents(UIControlEvents.TouchUpInside)  Comes for free
            self.sendActionsForControlEvents(UIControlEvents.TouchUpOutside)
            self.sendActionsForControlEvents(UIControlEvents.TouchCancel)
            */
        }
    }
    

    

    
    
    // MARK: -
    // MARK: Wheel Animation-per-frame methods
    func pop_animationDidApply(anim: Animation!) {
        
        if anim.name == "Basic Rotation" {
            if let basicRotation = wheelAnimations["Basic Rotation"] {
                let from = basicRotation.fromValue as! CGFloat
                let to = basicRotation.toValue as! CGFloat
                
                currentRotation = incrementRotation( currentRotation,
                                           forAngle: currentAngle,
                                         thatIsFrom: from,
                                                 to: to)
                
println("F:\(pad(from)) T:\(pad(to)) A:\(pad(currentAngle)) R:\(pad(currentRotation))")
                
                let direction = directionWhenRotationFrom(from, to: to)
                wheelRotatedTo(currentAngle, turningDirection: direction)
            }
        }
        
    }
    
    func incrementRotation(rotation: CGFloat,
                             forAngle angle: CGFloat,
                            thatIsFrom from: CGFloat,
                                         to: CGFloat) -> CGFloat {
            
        var newRotation = rotationForAngle(angle, thatIsFrom: from, to: to)
                                        
        let direction = directionWhenRotationFrom(from, to: to)

        if direction == .Clockwise {
            while newRotation > currentRotation {
                newRotation -= fullCircle
            }
        } else  {
            while newRotation < currentRotation {
                newRotation += fullCircle
            }
        }
                                        
        return newRotation
    }
    
    func directionWhenRotationFrom(from: CGFloat, to: CGFloat) -> DirectionRotated {
        let rotatingClockwise = from > to
        var direction: DirectionRotated
        if rotatingClockwise {
            direction = .Clockwise
        } else {
            direction = .CounterClockwise
        }
        return direction
    }
    
    func rotationForAngle(angle: CGFloat,
                        thatIsFrom from: CGFloat,
                                     to: CGFloat) -> CGFloat {
                            
        enum RangePlacement {
            case LessThan
            case Between
            case GreaterThan
        }
        
        func rangeCheck(n: CGFloat, minimum: CGFloat, maximum: CGFloat ) -> RangePlacement {
            switch n {
            case minimum...maximum:
                return .Between
            default:
                if n > maximum {
                    return .GreaterThan
                } else {
                    return .LessThan
                }
            }
        }
        
        var rotation = angle
        
        let minimum = min(to,from)
        let maximum = max(to,from)
        var rangeResult = rangeCheck(rotation, minimum, maximum)
        
        if rangeResult == .GreaterThan {
            while rotation > maximum {
                rotation -= fullCircle
            }
        }
        
        if rangeResult == .LessThan {
            while rotation < minimum {
                rotation += fullCircle
            }
        }
        
        return rotation
    }
    

    
    
    
    
    
    
    
    

    func wheelRotatedTo(angle: CGFloat,
           turningDirection direction: DirectionRotated) {
            

            setImageOpacityForCurrentAngle(angle)
            setImagesForCurrentState()
            //        println("currentImage \(currentState.image) wedgeValue \(currentState.wedgeValue) angle \(pad(angle)) additionalRotations: \(currentState.additionalRotations) previous additionalRotations: \(previousState.additionalRotations)")
            
    }
    
    func setImagesForCurrentState() {
        // TODO: swap out Images for Wedges
        
    }
    
    func setImageOpacityForCurrentAngle(var angle: CGFloat) {
        
        visualState.initOpacityListWithWedges(wedges)
        
        // Shift the rotation 1/2 a wedge width angle
        // This is to center the effect of changing the opacity.
        angle = angle + (wedgeWidthAngle / 2)
        angle = normalizAngle(angle)
        
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
        visualState.setOpacityOfWedgeImageViews(allWedgeImageViews)
    }
    
    
    func wheelWasTurnedBack() {
        
        // TODO: Fix math and simplify
        // Callback to notify there was a change to the wheel wedge position
//        var currentValue = currentWedgeValue
//        if currentValue > userState.initialWedge {
//            currentValue -= numberOfWedges
//        }
//        let wedgeCount = userState.initialWedge - currentValue
//        
//        let percentageStep = 1 / CGFloat((numberOfWedges - 1))
//        let percentage = percentageStep * CGFloat(wedgeCount)
//        println("turned back.  At % \(percentage)")
        
//        wheelTurnedBackBy(wedgeCount, AndPercentage: percentage)
    }
    
    
    
    // MARK: -
    // MARK: Image Rotation Methods (Without Animating)
    func rotateToImage(image: ImageIndex) {
        let wedge = wedgeForImage(image)
        rotateToWedge(wedge)
    }
    
    // MARK: Image Animation Methods
    func animateToImage(image: ImageIndex) {
        
        animateToImage( image, inDirection: .Closest)
    }
    
    
//    func animateToImage(image: ImageIndex,
//        inDirection direction: DirectionToRotate) {
//        
//        let resolved = resolveDirectionAndCountToImage( image,
//                                           inDirection: direction)
//        
//        var angle = currentWedge.midRadian
//        if resolved.direction == .Clockwise {
//            angle += CGFloat(resolved.count) * wedgeWidthAngle
//        } else {
//            angle -= CGFloat(resolved.count) * wedgeWidthAngle
//        }
//
//        animateToAngle(angle)
//    }
    
    func animateToImage(image: ImageIndex,
        inDirection direction: DirectionToRotate) {
        
        let resolved = resolveDirectionAndCountToImage( image,
                                           inDirection: direction)
        
        var rotation = rotationForAngle( currentWedge.midRadian,
                             thatIsFrom: (currentRotation - halfCircle),
                                     to: (currentRotation + halfCircle))
            
        if resolved.direction == .Clockwise {
            rotation += CGFloat(resolved.count) * wedgeWidthAngle
        } else {
            rotation -= CGFloat(resolved.count) * wedgeWidthAngle
        }

        animateToAngle(rotation)
    }
    
    
    func animateToAngle(rotation: CGFloat) {
        
        // TODO: use a logerithm to speed up longer rotations to a max of
        //       about 3/4 a full circle
        let durationPerWedge = CGFloat(0.25)
        let numberOfWedgesToRotate = (currentRotation - rotation) / wedgeWidthAngle
        let duration = abs(durationPerWedge * numberOfWedgesToRotate)
        
        let popRotate = BasicAnimation(duration: duration)
        
        popRotate.property = AnimatableProperty(name: kPOPLayerRotation)
        popRotate.fromValue = currentRotation
        popRotate.toValue = rotation
        popRotate.name = "Basic Rotation"
        popRotate.delegate = self
        popRotate.completionBlock = { anim, finished in
            self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
            self.wheelAnimations.removeValueForKey("Basic Rotation")
        }
        
        Animation.addAnimation( popRotate,
                           key: popRotate.name,
                           obj: self.container.layer)

        wheelAnimations["Basic Rotation"] = popRotate
        
        
        
        
        
        
//            let rotation = SpringAnimation(tension: 1000,
//                                          friction: 30,
//                                              mass: 1)
//            
//            rotation.property = AnimatableProperty(name: kPOPLayerRotation)
//            rotation.toValue = angle
//            rotation.name = "Spring Rotation"
//            rotation.delegate = self
//            rotation.completionBlock = { anim, finished in
//                self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
//            }
//            Animation.addAnimation( rotation,
//                               key: rotation.name,
//                               obj: self.container.layer)
        
    }
    
    func imageForWedge(             wedge: WedgeRegion,
                 WhileCurrentImageIs currentImage: ImageIndex) -> ImageIndex {
            
            var currentWedge = wedgeForImage(currentImage)
            let resolved = resolveDirectionAndCountToWedge( wedge,
                GivenCurrentWedge: currentWedge,
                inDirection: .Closest)
            
            let image: ImageIndex
            if resolved.direction == .Clockwise {
                // WAS: image = currentImage + resolved.count
                image = currentImage - resolved.count
            } else {
                // WAS: image = currentImage - resolved.count
                image = currentImage + resolved.count
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

    func resolveDirectionAndCountToImage(image: ImageIndex,
                             var inDirection direction: DirectionToRotate)
                                         -> (direction: DirectionToRotate,
                                                 count: Int) {
        let count: Int
        
        switch direction {
        case .Closest:
            // WAS: .Clockwise
            let positiveCount = countFromImage( currentImage,
                                       ToImage: image,
                                   inDirection: .CounterClockwise)
            // WAS: .CounterClockwise
            let negitiveCount = countFromImage( currentImage,
                                       ToImage: image,
                                   inDirection: .Clockwise)
            
            // WAS: .Clockwise
            if positiveCount <= negitiveCount {
                count     = positiveCount
                direction = .CounterClockwise
            } else {
                // WAS: .CounterClockwise
                count     = negitiveCount
                direction = .Clockwise
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
                
                
        assert(fromImage >= 1, "countFromImage: fromImage too low \(fromImage)")
        assert(toImage >= 1, "countFromImage: toImage too low \(toImage)")
        assert(fromImage <= images.count, "countFromImage: fromImage too high \(fromImage)")
        assert(toImage <= images.count, "countFromImage: toImage too high \(toImage)")

        var image = fromImage
        var count = 0
        while true {
            if image == toImage {
                break
            }
            // WAS: if direction == .Clockwise {
            if direction == .CounterClockwise {
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
            
            let normilizedAngle = normalizAngle(angle)
            let newRotation = currentAngle - normilizedAngle
            let t = CGAffineTransformRotate(container.transform, newRotation)
            container.transform = t;
            
            
            // TODO: Calculate direction
            // WAS: Clockwise
            wheelRotatedTo( normilizedAngle,
          turningDirection: .CounterClockwise)
        }
        self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
    }

    // MARK: Wedge Methods
    func resolveDirectionAndCountToWedge(wedge: WedgeRegion,
                             var inDirection direction: DirectionToRotate)
                                         -> (direction: DirectionToRotate,
                                                 count: Int) {
                                                    
         return resolveDirectionAndCountToWedge( wedge,
                              GivenCurrentWedge: self.currentWedge,
                                    inDirection: direction)
    }
    
    func resolveDirectionAndCountToWedge(wedge: WedgeRegion,
                        GivenCurrentWedge currentWedge: WedgeRegion,
                             var inDirection direction: DirectionToRotate)
                                        ->  (direction: DirectionToRotate,
                                                 count: Int) {
            
        let count: Int
        
        switch direction {
        case .Closest:
            // WAS: Clockwise
            let positiveCount = countFromWedgeValue( currentWedge.value,
                                       ToWedgeValue: wedge.value,
                                        inDirection: .CounterClockwise)
            // WAS: CounterClockwise
            let negitiveCount = countFromWedgeValue( currentWedge.value,
                                       ToWedgeValue: wedge.value,
                                        inDirection: .Clockwise)
            
            // WAS: Clockwise
            if positiveCount <= negitiveCount {
                count     = positiveCount
                direction = .CounterClockwise
            } else {
                // WAS: CounterClockwise
                count     = negitiveCount
                direction = .Clockwise
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
                         ToWedgeValue   toValue: Int,
                          inDirection direction: DirectionRotated) -> Int {
        
        var value = fromValue
        var count = 0
        while true {
            if value == toValue {
                break
            }
            // WAS: Clockwise
            if direction == .CounterClockwise {
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

    
    func thisAngle(angle: CGFloat,
        isWithinWedge wedge: WedgeRegion) -> Bool {
            var angleIsWithinWedge = false
            
            if (angle >= wedge.minRadian &&
                angle <= wedge.maxRadian   ) {
                    
                    angleIsWithinWedge = true
            }
            
            return angleIsWithinWedge
    }

    
    func wedgeForAngle(angle: CGFloat) -> WedgeRegion {
        
        let normAngle = normalizAngle(angle)
        
        // Determin where the wheel is (which wedge we are within)
        var currentWedge: WedgeRegion?
        for wedge in wedges {
            if thisAngle(normAngle, isWithinWedge: wedge) {
                currentWedge = wedge
                break
            }
        }
        assert(currentWedge != nil,"wedgeForAngle() may not be nil. Wedges do not fill the circle.")
        return currentWedge!
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
    


    
    
   // MARK: -
   // MARK: Whole Wheel Helpers
//    func calcUserStateForAngle(angle: CGFloat) {
//        checkIfWheelHasFlipped360(angle)
//        calcUserRotationDirectionWithAngle(angle)
//    }
//    
//    func checkIfWheelHasFlipped360(angle: CGFloat) {
//        // TODO: This is janky.  Is there bettter math???
//        if (userState.previousTouchAngle < -2) && (angle > 2) {
//            userState.wheelHasFlipped360 = true
//        }
//    }
//    
//    // TODO: remove and replace by calulating of initialRotation and currentRotation
//    func calcUserRotationDirectionWithAngle(angle: CGFloat) {
//        let angleDifference = userState.initialTouchAngle - angle
//        if angleDifference > 0 {
//            // WAS .Clockwise
//            userState.direction = .CounterClockwise
//        } else {
//            // WAS .CounterClockwise
//            userState.direction = .Clockwise
//        }
//    }

    
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
    func normalizAngle(var angle: CGFloat) -> CGFloat {
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

    func radiansFromTransform(transform: CGAffineTransform) -> CGFloat {
        let b = transform.b
        let a = transform.a
        let radians = atan2(b, a)
        
        return radians
    }
    
    func dampenRotationAngle(angle: CGFloat) -> CGFloat {
        return (log((angle * rotationDampeningFactor) + 1) / rotationDampeningFactor)
    }
    
    // MARK: Math Helpers
    func percentValue(value: CGFloat,
                 isBetweenLow   low: CGFloat,
                 AndHigh       high: CGFloat ) -> CGFloat {
        return (value - low) / (high - low)
    }
    
    // MARK: Debug printing methods
    // TODO: Remove after main developement
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

