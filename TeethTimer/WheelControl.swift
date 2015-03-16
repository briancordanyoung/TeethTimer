import UIKit

typealias ImageIndex = Int

struct WheelState {
    static let initialVelocity: CGFloat = 0.0000001

    var currentRotation: CGFloat  =  0.0
    var previousRotation: CGFloat = -initialVelocity
    var previousDirection: DirectionRotated = .Clockwise

    init() {
      currentRotation   =  0.0
      previousRotation  = -WheelState.initialVelocity
      previousDirection = .Clockwise

  }
    
    init( currentRotation: CGFloat,
         previousRotation: CGFloat,
        previousDirection: DirectionRotated) {
            self.currentRotation = currentRotation
            self.previousRotation = previousRotation
            self.previousDirection = previousDirection
    }
    
    init(angle: CGFloat) {
        self.init(currentRotation: angle,
            previousRotation: angle - WheelState.initialVelocity,
            previousDirection: .Clockwise)
    }
}

enum DampenAngle {
  case no
  case atAngle(CGFloat)
}

struct DampenDirection {
  var clockwise:        DampenAngle = .no
  var counterClockwise: DampenAngle = .no
}

struct DirectionToggle {
    var clockwise        = false
    var counterClockwise = false
}

enum DirectionToRotate: String, Printable  {
    case Clockwise = "Clockwise"
    case CounterClockwise = "CounterClockwise"
    case Closest = "Closest"

    var description: String {
        return self.rawValue
    }
}

enum DirectionRotated: String, Printable {
    case Clockwise = "Clockwise"
    case CounterClockwise = "CounterClockwise"

    var description: String {
        return self.rawValue
    }
}

enum Parity: String, Printable  {
    case Even = "Even"
    case Odd = "Odd"

    var description: String {
        return self.rawValue
    }
}

enum WheelRegion: String, Printable  {
    case On = "On"
    case Off = "Off"
    case Center = "Center"

    var description: String {
        return self.rawValue
    }
}

private let halfCircle = CGFloat(M_PI)
private let fullCircle = CGFloat(M_PI) * 2
private let quarterCircle = CGFloat(M_PI) / 2
private let threeQuarterCircle = quarterCircle + halfCircle

final class WheelControl: UIControl, AnimationDelegate  {
  // Configure WheelControl
  var startingRotation: CGFloat = fullCircle * 3
  
  var minRotation: CGFloat?    = nil
  var maxRotation: CGFloat?    = nil
  var dampenClockwise          = false
  var dampenCounterClockwise   = false
  
  // How strong should the users rotation be dampened as they
  // rotate past the allowed point
  var rotationDampeningFactor  = CGFloat(5)
  
  var centerCircle: CGFloat =  10.0
  
  
  
  
  // Internal Properties
  private var container = UIView()

  private var outsideCircle: CGFloat {
      return container.bounds.height * 2
  }
  
  private var currentAngle: CGFloat {
      return angleFromTransform(container.transform)
  }
  
  // See: rotationFromAngle(_,AndWheelState:) for and explination of the
  // the wheelState property and struct.
  var wheelState = WheelState()

  // See: rotationFromAngle(_,AndWheelState:) for and explination of the
  // the currentRotation property, wheelState property and backing struct.
  var currentRotation: CGFloat {
    
    get {
      return wheelState.currentRotation
    }
    
    set(newAngle) {
      let newRotation = rotationFromAngle( newAngle, AndWheelState: wheelState)
      
      let newDirection: DirectionRotated
      if newRotation > wheelState.currentRotation {
        newDirection = .Clockwise
      } else if newRotation < wheelState.currentRotation {
        newDirection = .CounterClockwise
      } else {
        newDirection = wheelState.previousDirection
      }
      
      wheelState = WheelState( currentRotation: newRotation,
                              previousRotation: wheelState.currentRotation,
                             previousDirection: newDirection)
    }
  }

  // See: The UIControl methods handling the touches to understand userState
  //      beginTrackingWithTouch(_,withEvent:)
  //      continueTrackingWithTouch(_,withEvent:)
  //      endTrackingWithTouch(_,withEvent:)
  private var userState   = ImageWheelInteractionState()

  

  
  func addConstraintsToViews() {
    container.userInteractionEnabled = false
    self.addSubview(container)
    
    self.setTranslatesAutoresizingMaskIntoConstraints(false)
    container.setTranslatesAutoresizingMaskIntoConstraints(false)
    
    
    // constraints
    let viewsDictionary = ["controlView":container]
    
    //position constraints
    let view_constraint_H:[AnyObject] =
    NSLayoutConstraint.constraintsWithVisualFormat( "H:|[controlView]|",
                                           options: NSLayoutFormatOptions(0),
                                           metrics: nil,
                                             views: viewsDictionary)
    
    let view_constraint_V:[AnyObject] =
    NSLayoutConstraint.constraintsWithVisualFormat( "V:|[controlView]|",
                                           options: NSLayoutFormatOptions(0),
                                           metrics: nil,
                                             views: viewsDictionary)
    
    self.addConstraints(view_constraint_H)
    self.addConstraints(view_constraint_V)
    
    let wheelImageView     = UIImageView(image: UIImage(named: "WheelImage"))
    let wheelImageTypeView = UIImageView(image: UIImage(named: "WheelImageType"))
    
    wheelImageView.opaque = false
    wheelImageTypeView.opaque = false
    
    container.addSubview(wheelImageView)
    container.addSubview(wheelImageTypeView)
    
    
    wheelImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
    wheelImageTypeView.setTranslatesAutoresizingMaskIntoConstraints(false)
    
    container.addConstraint(NSLayoutConstraint(item: wheelImageView,
                                          attribute: NSLayoutAttribute.CenterY,
                                          relatedBy: NSLayoutRelation.Equal,
                                             toItem: container,
                                          attribute: NSLayoutAttribute.CenterY,
                                         multiplier: 1.0,
                                           constant: 0.0))
    
    container.addConstraint(NSLayoutConstraint(item: wheelImageView,
                                          attribute: NSLayoutAttribute.CenterX,
                                          relatedBy: NSLayoutRelation.Equal,
                                             toItem: container,
                                          attribute: NSLayoutAttribute.CenterX,
                                         multiplier: 1.0,
                                           constant: 0.0))
    
    wheelImageView.addConstraint( NSLayoutConstraint(item: wheelImageView,
                                                attribute: NSLayoutAttribute.Height,
                                                relatedBy: NSLayoutRelation.Equal,
                                                   toItem: nil,
                                                attribute: NSLayoutAttribute.NotAnAttribute,
                                               multiplier: 1.0,
                                                 constant: 600.0))
    
    wheelImageView.addConstraint( NSLayoutConstraint(item: wheelImageView,
                                                attribute: NSLayoutAttribute.Width,
                                                relatedBy: NSLayoutRelation.Equal,
                                                   toItem: nil,
                                                attribute: NSLayoutAttribute.NotAnAttribute,
                                               multiplier: 1.0,
                                                 constant: 600.0))
    
    container.addConstraint(NSLayoutConstraint(item: wheelImageTypeView,
                                          attribute: NSLayoutAttribute.CenterY,
                                          relatedBy: NSLayoutRelation.Equal,
                                             toItem: container,
                                          attribute: NSLayoutAttribute.CenterY,
                                         multiplier: 1.0,
                                           constant: 0.0))
    
    container.addConstraint(NSLayoutConstraint(item: wheelImageTypeView,
                                          attribute: NSLayoutAttribute.CenterX,
                                          relatedBy: NSLayoutRelation.Equal,
                                             toItem: container,
                                          attribute: NSLayoutAttribute.CenterX,
                                         multiplier: 1.0,
                                           constant: 0.0))
    
    wheelImageTypeView.addConstraint( NSLayoutConstraint(item: wheelImageTypeView,
                                                    attribute: NSLayoutAttribute.Height,
                                                    relatedBy: NSLayoutRelation.Equal,
                                                       toItem: nil,
                                                    attribute: NSLayoutAttribute.NotAnAttribute,
                                                   multiplier: 1.0,
                                                     constant: 400.0))
    
    wheelImageTypeView.addConstraint( NSLayoutConstraint(item: wheelImageTypeView,
                                                    attribute: NSLayoutAttribute.Width,
                                                    relatedBy: NSLayoutRelation.Equal,
                                                       toItem: nil,
                                                    attribute: NSLayoutAttribute.NotAnAttribute,
                                                   multiplier: 1.0,
                                                     constant: 400.0))
    
    reset()
  }
  
  
  func reset() {
    startingRotation = -halfCircle
    minRotation = startingRotation
    maxRotation = startingRotation + fullCircle + threeQuarterCircle
    
    wheelState = WheelState(currentRotation: startingRotation,
                           previousRotation: startingRotation,
                          previousDirection: .Clockwise)
    container.transform = CGAffineTransformMakeRotation(angleFromRotation(currentRotation))
    
  }
  
  // MARK: -
  // MARK: UIControl methods handling the touches
  override func beginTrackingWithTouch(touch: UITouch,
                             withEvent event: UIEvent) -> Bool {
      
    if touchRegion(touch) == .Center {
      return false  // Ends current touches to the control
    }

                            
    Animation.removeAllAnimations(container.layer)
                            
    // Clear and set state at the beginning of the users rotation
    userState                    = ImageWheelInteractionState()
    userState.currently          = .Interacting
    userState.initialTransform   = container.transform
    userState.initialRotation    = currentRotation
    userState.initialTouchAngle  = angleAtTouch(touch)
    
    if let min = minRotation {
      userState.minDampenAngle   = -(currentRotation - min)
    }
    if let max = maxRotation {
      userState.maxDampenAngle   =   max - currentRotation
    }
    
    
    return beginAndContinueTrackingWithTouch( touch, withEvent: event)
  }
  
  override func continueTrackingWithTouch(touch: UITouch,
                                withEvent event: UIEvent) -> Bool {
      
    return beginAndContinueTrackingWithTouch( touch, withEvent: event)
  }
  
  private func beginAndContinueTrackingWithTouch(touch: UITouch,
                                       withEvent event: UIEvent) -> Bool {
    switch touchRegion(touch) {
    case .Off:
      self.sendActionsForControlEvents(UIControlEvents.TouchDragOutside)
      self.sendActionsForControlEvents(UIControlEvents.TouchUpOutside)
      endTrackingWithTouch(touch, withEvent: event)
      return false  // Ends current touches to the control
    case .Center:
      self.sendActionsForControlEvents(UIControlEvents.TouchDragExit)
      endTrackingWithTouch(touch, withEvent: event)
      return false  // Ends current touches to the control
    case .On:
      break // continueTrackingWithTouch
    }
    
    let angleDifference = angleDifferenceUsing(touch)
    
    let t = CGAffineTransformRotate( userState.initialTransform, angleDifference )
    container.transform = t
    currentRotation = userState.initialRotation + angleDifference
    
    self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
    self.sendActionsForControlEvents(UIControlEvents.TouchDragInside)
    
    return true
  }
  
  override func endTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) {
    
    // User interaction has ended, but most of the state is
    // still used through out this method.
    userState.currently = .NotInteracting
    
    switch userState.snapTo {
    case .InitialRotation:
      animateToRotation(userState.initialRotation)
      break
    case .CurrentRotation:
      break
    case .MinRotation:
      if let rotation = minRotation {
        animateToRotation(rotation)
      }
    case .MaxRotation:
      if let rotation = maxRotation {
        animateToRotation(rotation)
      }
    }
    
    // User rotation has ended.  Forget the state.
    userState = ImageWheelInteractionState()
    
  }
  

  // MARK: -
  // MARK: Animation
  
//    private func animateToRotation(rotation: CGFloat) {
//        Animation.removeAllAnimations(container.layer)
//        let currentRotation = self.currentRotation
//        
//        let springAngularDistance = halfCircle / 3
//        let totalAngularDistance = abs(currentRotation - rotation)
//        
//        if totalAngularDistance <= springAngularDistance {
//            springRotationAnimation( from: currentRotation,
//                                       to: rotation)
//        } else {
//            let durationPerRadian = CGFloat(0.25)
//            let baseDuration = totalAngularDistance * durationPerRadian
//            let totalDuration = speedUpDurationByDistance(baseDuration)
//            
//            let part1Distance    = totalAngularDistance - springAngularDistance
//            let part1Percentage  = part1Distance / totalAngularDistance
//            let part1Duration    = totalDuration * part1Percentage
//            let part1Rotation    = ((rotation - currentRotation ) * part1Percentage) + currentRotation
//            
//            basicRotationAnimation( from: currentRotation,
//                                      to: part1Rotation,
//                duration: part1Duration) { anim, finsihed in
//                    self.springRotationAnimation(from: part1Rotation,
//                                                   to: rotation)
//            }
//            
//        }
//    }
    
  private func animateToRotation(rotation: CGFloat) {
    Animation.removeAllAnimations(container.layer)
    let durationPerRadian = CGFloat(0.25)
    let totalAngularDistance = abs(currentRotation - rotation)
    let baseDuration = totalAngularDistance * durationPerRadian
    let totalDuration = speedUpDurationByDistance(baseDuration)
    let timing = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    
    let rotate = BasicAnimation(duration: totalDuration, timingFunction: timing)
    rotate.property = AnimatableProperty(name: kPOPLayerRotation)
    rotate.fromValue = currentRotation
    rotate.toValue = rotation
    rotate.name = "Basic Rotation"
    rotate.delegate = self
    rotate.completionBlock = { anim, finished in
      if finished {
        self.wheelState.currentRotation = rotation
        self.wheelState.previousRotation = rotation
        self.wheelState.previousDirection  = .Clockwise
        let t = CGAffineTransformMakeRotation(self.angleFromRotation(rotation))
        self.container.transform = t
      }
    }
    
    Animation.addAnimation( rotate,
      key: rotate.property.name,
      obj: container.layer)
  }
  
  func speedUpDurationByDistance(duration: CGFloat) -> CGFloat {
    let durationDistanceFactor = CGFloat(1)
    return log((duration * durationDistanceFactor) + 1) / durationDistanceFactor
  }
  
  func basicRotationAnimation(#from: CGFloat,
                                 to: CGFloat,
                           duration: CGFloat,
                         completion: (Animation, Bool)->()) {
                          
    let rotate = BasicAnimation(duration: duration)
    rotate.property = AnimatableProperty(name: kPOPLayerRotation)
    rotate.fromValue = from
    rotate.toValue = to
    rotate.name = "Basic Rotation"
    rotate.delegate = self
    Animation.addAnimation( rotate,
                       key: rotate.property.name,
                       obj: container.layer)
    
  }

  
  func springRotationAnimation(#from: CGFloat, to: CGFloat) {
    
    let spring = SpringAnimation( tension: 1000,
                        friction: 30,
                            mass: 1)
    spring.property = AnimatableProperty(name: kPOPLayerRotation)
    spring.fromValue = from
    spring.toValue = to
    spring.name = "Spring Rotation"
    spring.delegate = self
    spring.completionBlock = { anim, finished in
      if finished {
        self.currentRotation = to
        let t = CGAffineTransformMakeRotation(self.angleFromRotation(to))
        self.container.transform = t
      }
    }
    Animation.addAnimation( spring,
                       key: spring.property.name,
                       obj: container.layer)
  }
  
    func pop_animationDidApply(anim: Animation!) {
        let angle = angleFromRotation(wheelState.previousRotation)
        let angleDifference = currentAngle - angle
        currentRotation = currentRotation + angleDifference
        self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
    }
    
  func test() {
    let step1 = currentRotation
    let step2 = maxRotation
    let step3 = maxRotation
    
    let rotate = BasicAnimation(duration: 2.0,
      timingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn))
    rotate.property = AnimatableProperty(name: kPOPLayerRotation)
    rotate.fromValue = step1
    rotate.toValue = step2
    rotate.name = "Basic Rotation"
    rotate.delegate = self
    rotate.completionBlock = {anim, finsihed in
      if finsihed {
        let spring = SpringAnimation( tension: 100,
                                     friction: 15,
                                         mass: 1)
        spring.property = AnimatableProperty(name: kPOPLayerRotation)
        spring.fromValue = step2
        spring.toValue = step3
        spring.name = "Spring Rotation"
        spring.delegate = self
        Animation.addAnimation( spring,
                           key: spring.property.name,
                           obj: self.container.layer)
      }
    }
    Animation.addAnimation( rotate,
                       key: rotate.property.name,
                       obj: container.layer)
  }
  

  // MARK: -
  // MARK: Development Helpers
  // TODO: Remove after main development
  private lazy var padNumber: NSNumberFormatter = {
    let numberFormater = NSNumberFormatter()
    numberFormater.minimumIntegerDigits  = 2
    numberFormater.maximumIntegerDigits  = 2
    numberFormater.minimumFractionDigits = 3
    numberFormater.maximumFractionDigits = 3
    numberFormater.positivePrefix = " "
    return numberFormater
    }()
  
  private func pad(number: CGFloat) -> String {
    var paddedNumber = " 1.000"
    if let numberString = padNumber.stringFromNumber(number) {
      paddedNumber = numberString
    }
    return paddedNumber
  }

  // MARK: Wheel State
  private func rotationFromAngle(angle: CGFloat,
              AndWheelState wheelState: WheelState) -> CGFloat {
                
      // This method is a hack!  This class is based on the idea that the
      // accumulated rotation angle (in radians) can be known.
      // At the time of this method, only the absolute angle from -3.14 to 3.14
      // can be determined. Unless another API is pointed out, this method
      // is used to make a best guess on tracking the accumulated rotations
      // of the wheel as it passes over the dicontinuity of the absolute angle
      // returned from the affine transform.
                
      // In various conditions, this algorithm breaks down and can not
      // determin the correct accumulated rotation.  It returns the last
      // know good state in the hopes that the next evaluation can figure it out.
                
      // Overly large jumps between evaluations may produce the wrong guess.
      // Execptionally fast rotations from the user or animation could do this.
                
      // During user interaction, this works. The angle difference from the initial
      // touch is recalculated each time, so ONLY the final evaluation of
      // this method, when touch ends, is used to keep the rotation in sync
      // with the current absolute angle.
                
      // During animations, it is best to use the expected end state of the
      // animation to set the currentRotation property to the expected value,
      // (or more precicly, the wheelState property holding backing struct)
      // overriding the accumulated changes made throughout the animation
      
                
      // TODO: track down rare exeption landing here:
      //       Thread 1: EXC_BAD_INSTRUCTION (code=EXC_i386_INVOP,subcode=0x0)
                
      let rotationCountFromZero = Int(abs(angle / fullCircle))
      let tooManyTries          = rotationCountFromZero + 2
      
      var rotation = angle
      
      var difference = abs(wheelState.currentRotation - rotation)
      var previousDifference = difference
      
      // When rotating over the dicontinuity between
      // the -3.14 and 3.14 angles, we need to figure out
      // the what to add/substract from rotation to
      // keep incrementing the rotation in the correct direction
      var addOrSubtract = true
      var tries: [String] = []
                
      // TODO: Test how close to a full circle the difference can be compared to.
      //       the closer to 2 * M_PI we get, the less room for problems during
      //       fast rotations.
      while difference > threeQuarterCircle {
        if difference >= previousDifference {
          addOrSubtract = !addOrSubtract
        }
        if addOrSubtract {
          rotation -= fullCircle
          tries.append("Rotation After Adding:      \(rotation) d:\(difference)")
        } else {
          rotation += fullCircle
          tries.append("Rotation After Subtracting: \(rotation) d:\(difference)")
        }
        previousDifference = difference
        difference = abs(wheelState.currentRotation - rotation)
        
        // The algorithm has gone all wrong.
        // This is a safty to break out of the loop
        // and continue on with the previously saved state
        if tries.count > tooManyTries {
          rotation = wheelState.currentRotation
          NSLog("Error: WheelControl could not calculate total rotation when passing over the discontinuity. Tried \(tries.count) times.")
          for try in tries {
            NSLog(try)
          }
          break // break out of the while loop
        }
      }
      
      return rotation
  }

  private func angleDifferenceUsing(touch: UITouch) -> CGFloat {
    
    let angleDiff = angleDifferenceBetweenTouch( touch,
                                       AndAngle: userState.initialTouchAngle)
    
    var dampenedDiff = angleDiff
    
    // TODO: Should undampenedNewRotation be feed in to directionsToDampenUsingAngle()?
    //       seems like it should be userState.initialAngle + angleDiff
    //       but that doesn't work.
    let undampenedNewRotation = userState.initialRotation + angleDiff
    
    var dampen = directionsToDampenUsingAngle(undampenedNewRotation)
    
    switch dampen.clockwise {
      case .atAngle(let startAngle):
        dampenedDiff = dampenClockwiseAngleDifference( angleDiff,
                                      startingAtAngle: startAngle)
      case .no:
      break
    }

    switch dampen.counterClockwise {
    case .atAngle(let startAngle):
      dampenedDiff = dampenCounterClockwiseAngleDifference( angleDiff,
                                           startingAtAngle: startAngle)
    case .no:
      break
    }
    
    return dampenedDiff
  }
  
  
  private func directionsToDampenUsingAngle(angle: CGFloat) -> DampenDirection {

    // Each change in the touch angle of the WheelControl calls
    // directionsToDampenUsingAngle()  At each check, assume that
    // the userState.snapTo should be .CurrentRotation until the angle
    // is evaluated.
    userState.snapTo = .CurrentRotation
    
    // Assume also that their is no dampening to be done at this angle
    // until it is evaluated below. New DampenDirection structs are '.no' in
    // both directions.
    var dampenRotation  = DampenDirection()
    
    
    // Determine what WOULD the new currentRotation be at this angle
    // IF there was no dampening of the rotation.  Use this to judge
    // if the angle needs to be dampened.
    let rotation = rotationFromAngle(angle, AndWheelState: wheelState)
    
    
    // Check for the optional minRotation & maxRotation properties.
    // If they exist, the wheel is limited in how far it may rotate.
    // We need to pass back via the dampenRotation varriable, at what angle to
    // start dampening the rotation.  This number (passed in the .atAngle() enum)
    // is the difference in the angle between the user begining to rotate,
    // and the angle to start dampening.
    
    // Also set the userState to snapTo what possition after the 
    // user interaction is complete.
    
    if let min = minRotation {
      if rotation < min {
        dampenRotation.counterClockwise = .atAngle(userState.minDampenAngle)
        userState.snapTo = .MinRotation
      }
    }
    if let max = maxRotation {
      if rotation > max {
        dampenRotation.clockwise = .atAngle(userState.maxDampenAngle)
        userState.snapTo = .MaxRotation
      }
    }
    
    
    // If the dampenClockwise or dampenCounterClockwise properties are set,
    // they override the either minRotation & maxRotation and set the
    // dampening to begin imediately on user interaction.
    if rotation > userState.initialRotation && dampenClockwise {
      dampenRotation.clockwise = .atAngle(0.0)
      userState.snapTo = .InitialRotation
    }
    
    if rotation < userState.initialRotation && dampenCounterClockwise {
      dampenRotation.counterClockwise = .atAngle(0.0)
      userState.snapTo = .InitialRotation
    }
    
    return dampenRotation
  }
  
    // MARK: Wheel State Helpers
  private func angleDifferenceBetweenTouch( touch: UITouch,
    AndAngle angle: CGFloat) -> CGFloat {
      let touchAngle = angleAtTouch(touch)
      var angleDifference = angle - touchAngle
      
      // Notice the angleDifference is flipped to negitive
      return -angleDifference
  }
  
  private func dampenClockwiseAngleDifference(var angle: CGFloat,
                             startingAtAngle startAngle: CGFloat) -> CGFloat {
    
    // To prevent NaN result assume positive angles are still positive by
    // subtracting a full 2 radians from the angle. This does not allow for
    // beyond full 360° rotations, but works up to 360° before it snaps back.
    // dampening infinately rotations would require tracking previous angle.
    
    while angle <= 0 {
      angle += fullCircle
    }
    angle -= startAngle
    angle  = (log((angle * rotationDampeningFactor) + 1) / rotationDampeningFactor)
    angle += startAngle
                          
    return angle
  }
  
  private func dampenCounterClockwiseAngleDifference(var angle: CGFloat,
                                    startingAtAngle startAngle: CGFloat) -> CGFloat {
    angle = -angle
    angle = dampenClockwiseAngleDifference(angle, startingAtAngle: -startAngle)
    angle = -angle
    
    return angle
  }
  
    // MARK: UITouch Helpers
  private func touchPointWithTouch(touch: UITouch) -> CGPoint {
    return touch.locationInView(self)
  }
  
  private func angleAtTouch(touch: UITouch) -> CGFloat {
    let touchPoint = touchPointWithTouch(touch)
    return angleAtTouchPoint(touchPoint)
  }
  
  
  private func angleAtTouchPoint(touchPoint: CGPoint) -> CGFloat {
    let dx = touchPoint.x - container.center.x
    let dy = touchPoint.y - container.center.y
    var angle = atan2(dy,dx)
    
    // Somewhere in the rotation of the container will be a discontinuity
    // where the angle flips from -3.14 to 3.14 or  back.  This adgustment
    // places that point in negitive Y.
    if angle >= quarterCircle {
      angle = angle - fullCircle
    }
    return angle
  }
  
  
  private func distanceFromCenterWithTouch(touch: UITouch) -> CGFloat {
    let touchPoint = touchPointWithTouch(touch)
    return distanceFromCenterWithPoint(touchPoint)
  }
  
  private func distanceFromCenterWithPoint(point: CGPoint) -> CGFloat {
    let center = CGPointMake(self.bounds.size.width  / 2.0,
      self.bounds.size.height / 2.0)
    
    return distanceBetweenPointA(center, AndPointB: point)
  }
  
  private func distanceBetweenPointA(pointA: CGPoint,
    AndPointB pointB: CGPoint) -> CGFloat {
      let dx = pointA.x - pointB.x
      let dy = pointA.y - pointB.y
      let sqrtOf = dx * dx + dy * dy
      
      return sqrt(sqrtOf)
  }
  
  private func touchRegion(touch: UITouch) -> WheelRegion {
    
    let dist = distanceFromCenterWithTouch(touch)
    var region: WheelRegion = .On
    
    if (dist < centerCircle) {
      region = .Center
    }
    if (dist > outsideCircle) {
      region = .Off
    }
    
    return region
  }
  

  // MARK: Angle Helpers
  private func angleFromRotation(rotation: CGFloat) -> CGFloat {
    var angle = rotation
    
    if angle >  halfCircle {
      angle += halfCircle
      let totalRotations = floor(angle / fullCircle)
      angle  = angle - (fullCircle * totalRotations)
      angle -= halfCircle
    }
    
    if angle < -halfCircle {
      angle -= halfCircle
      let totalRotations = floor(abs(angle) / fullCircle)
      angle  = angle + (fullCircle * totalRotations)
      angle += halfCircle
    }
    
    return angle
  }
  
  
  private func normalizAngle(var angle: CGFloat) -> CGFloat {
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

  private func angleFromTransform(transform: CGAffineTransform) -> CGFloat {
    let b = transform.b
    let a = transform.a
    let angle = atan2(b, a)
    
    return angle
  }

}