// MARK: - WheelControl Summery

// Wheel Control
// 
//               The public API to WheelControl value (position) is set and get
//               using the rotationAngle property.
//               This is never referenced internally.
//               Instead two properties are used:
//                    currentAngle
//                    currentRotation
//
// The difference between an angle and rotation is:
//
//    angle    - Ranges from -M_PI to M_PI (in radians)
//
//
//    rotation - Has no theoretical min and max. (in radians)
//               Rotation may be used to notate the absolute number
//               of complete rotations around the wheel.
//               Rotation acculmulates in each direction where the angle
//               wraps around when passing min or max returning to the other.
//
//               i.e.:
//               angle    - 0.0   1.0   2.0   3.0  -2.28 -1.28 -0.28  0.71  1.71
//               rotation - 0.0   1.0   2.0   3.0   4.00  5.00  6.00  7.00  8.00
//
//    currentAngle & currentRotation:
//               These properties are independant,  They are related, but if one
//               is modified, the other is not automaticly kept in sync.  That
//               must be done by the internal developer. rotationAngle DOES set
//               both prperties, and that is why it is the only public property
//               for working with the wheel position.
//
//               There is only one correct angle for any one rotation.
//               Do not try to offset the angle from the rotation.
//               Any offset in currentAngle will eventually be reset and synced
//               to currentRotation.
//
//               The control only fires the ValueChange event when 
//               currentRotation is modified.





import UIKit


// MARK: -
// MARK: - Enums
enum DirectionRotated: String, Printable {
    case Clockwise        = "Clockwise"
    case CounterClockwise = "CounterClockwise"

    var description: String {
        return self.rawValue
    }
}

enum WheelRegion: String, Printable  {
    case On     = "On"
    case Off    = "Off"
    case Center = "Center"

    var description: String {
        return self.rawValue
    }
}

enum DampenAngle: Printable {
  case no
  case atAngle(Angle)

  var description: String {
    switch self {
      case no:
        return "<none>"
      case atAngle(let angle):
        return "\(angle)"
    }
  }
}

enum SnapWheelTo: String, Printable {
  case InitialRotation = "InitialRotation"
  case CurrentRotation = "CurrentRotation"
  case MinRotation     = "MinRotation"
  case MaxRotation     = "MaxRotation"
  
  var description: String {
    return self.rawValue
  }
}

enum InteractionState: String, Printable {
  case Interacting    = "Interacting"
  case NotInteracting = "NotInteracting"
  
  var description: String {
    return self.rawValue
  }
}

enum AnimationState: String, Printable {
  case AnimationInMotion  = "Animation In Motion"
  case AtRest             = "At Rest"
  
  var description: String {
    return self.rawValue
  }
}

// MARK: -
// MARK: - Structs
struct WheelState: Printable {
  static let initialVelocity: Angle = 0.0000001
  
  var currentRotation:   Angle
  var previousRotation:  Angle
  var previousDirection: DirectionRotated
  var targetRotation:    Angle?
  
  init() {
    currentRotation   =  0.0
    previousRotation  = -WheelState.initialVelocity
    previousDirection = .Clockwise
    
  }
  
  init( currentRotation: Angle,
       previousRotation: Angle,
      previousDirection: DirectionRotated) {
      self.currentRotation   = currentRotation
      self.previousRotation  = previousRotation
      self.previousDirection = previousDirection
  }
  
  init(angle: Angle) {
    self.init(currentRotation: angle,
             previousRotation: angle - WheelState.initialVelocity,
            previousDirection: .Clockwise)
  }

  var description: String {
    var msg =  "Current Rotation: \(currentRotation) "
    msg    +=  "Previous Rotation: \(previousRotation) "
    msg    +=  "Previous Cirection: \(previousDirection)"
    return msg
  }
}

struct WheelInteractionState {
  
  var initialTransform:  CGAffineTransform
  var initialTouchAngle: Angle
  var initialRotation:   Angle
  var maxDampenAngle:    Angle
  var minDampenAngle:    Angle
  
  var currently: InteractionState
  var snapTo:    SnapWheelTo
  
  init() {
    initialTransform   = CGAffineTransformMakeRotation(0)
    initialTouchAngle  = 0.0
    initialRotation    = 0.0
    currently          = .NotInteracting
    snapTo             = .CurrentRotation
    maxDampenAngle     =  Angle(DBL_MAX)
    minDampenAngle     = -Angle(DBL_MAX)
  }
}

struct DampenDirection: Printable {
  var clockwise:        DampenAngle = .no
  var counterClockwise: DampenAngle = .no
  
  var description: String {
    var msg = "Dampen when angle difference reaches: \(clockwise) (Clockwise) "
    msg    += "or \(counterClockwise) (Counter Clockwise)"
    return msg
  }
}


//struct Circle {
//  static let half         =  Angle(M_PI)
//  static let full         =  Angle(M_PI) * 2
//  static let quarter      =  Angle(M_PI) / 2
//  static let threeQuarter = (Angle(M_PI) / 2) + Angle(M_PI)
//  
//  
//  func radian2Degree(radian:Angle) -> Angle {
//    return radian * 180.0 / Angle(M_PI)
//  }
//  
//  func degreesToRadians (value:Angle) -> Angle {
//    return value * Angle(M_PI) / 180.0
//  }
//}





// MARK: -
// MARK: - WheelControl Class
final class WheelControl: UIControl, AnimationDelegate  {

  // The data of WheelControl
  // Do not use this internally.
  // This is the only interface for getting the data for this control.
  // Externally set the data for this control with this property or 
  //                                                animateToRotation()
  var rotationAngle: Angle {  // in module, make public //
    get {
      return currentRotation - internalRotationOffset
    }
    set(newRotationAngle) {

      let adjustRotationAngle = newRotationAngle + internalRotationOffset
      
      currentAngle = angleFromRotation(adjustRotationAngle)
      currentRotation = adjustRotationAngle
    }
  }
  
  var percentageLeft: CGFloat? {
    get {
      var percentageLeft: CGFloat?
      if let min = minimumRotation, max = maximumRotation {
        let current = rotationAngle
        percentageLeft = percentValue( current.cgRadians,
                         isBetweenLow: min.cgRadians,
                              AndHigh: max.cgRadians)
      }
      return percentageLeft
    }
  }
  
  func percentValue(value: CGFloat,
        isBetweenLow  low: CGFloat,
        AndHigh      high: CGFloat ) -> CGFloat {
      return (value - low) / (high - low)
  }
  
  var targetRotationAngle: Angle {  // in module, make public //
      var targetRotationAngle = rotationAngle
      if let target = wheelState.targetRotation {
        targetRotationAngle = target - internalRotationOffset
      }
      return targetRotationAngle
  }
  
  var animationState: AnimationState {
    
    let animations = Animation.animations(wheelView.layer)
    
    let state: AnimationState
    if animations.count == 0 {
      state = .AtRest
    } else {
      state = .AnimationInMotion
    }
    
    return state
  }
  
  // Configure WheelControl
  var centerCircle:      CGFloat = 10.0
  var startingRotation:  Angle =  0.0
  let wheelView                  = UIView()
  var backgroundView: UIView {
    return self
  }


  var snapToRotation: Angle?

  // Configure Dampening Properties
  var dampenClockwise          = false
  var dampenCounterClockwise   = false
  var minimumRotation: Angle? {
    get {
      return minRotation
    }
    set(newMinRotation) {
      if let newMinRotation = newMinRotation {
        let newMinRotationWithOffset = newMinRotation + internalRotationOffset

        let msg = "minRotation must be less than or equal to rotationAngle."
        assert(currentRotation >= newMinRotationWithOffset, msg)
        
        minRotation = newMinRotationWithOffset
      } else {
        minRotation = nil
      }
    }
  }
  var maximumRotation: Angle? {
    get {
      return maxRotation
    }
    set(newMaxRotation) {
      if let newMaxRotation = newMaxRotation {
        let newMaxRotationWithOffset = newMaxRotation + internalRotationOffset
        
        let msg = "maxRotation must be greater than or equal to rotationAngle."
        assert(newMaxRotationWithOffset >= currentRotation, msg)
        
        maxRotation = newMaxRotationWithOffset
      } else {
        maxRotation = nil
      }
    }
  }

  
  // How strong should the users rotation be dampened as they
  // rotate past the allowed point
  var rotationDampeningFactor  = CGFloat(5)
  
  
  // Internal Properties
  
  var minRotation: Angle?
  var maxRotation: Angle?
  
  
  // The method rotationUsingAngle(AndWheelState:) is a hack to try and figure
  // out what the currentRotation should be.  That method has less problems when
  // the rotation is greater than 0.  This offset is used to internally add
  // to the currentRotation.  The public properties that are used outside this
  // class will add/subtract this offset when set/get.
  
  // TODO: This is currently not working.  Must debug
  //  let internalRotationOffset = Angle(Circle.full * 3)
  let internalRotationOffset = Angle(0)

  var outsideCircle: CGFloat {
      return wheelView.bounds.height * 2
  }
  
  var currentAngle: Angle {
    get {
      return angleFromTransform(wheelView.transform)
    }
    set(newAngle) {
      wheelView.transform = CGAffineTransformMakeRotation(newAngle.cgRadians)
    }
  }
  
  // See: rotationFromAngle(_,AndWheelState:) for and explination of the
  // the wheelState property and struct.
  var wheelState = WheelState()



  // See: rotationUseingAngle() for and explination of the
  // the currentRotation property, wheelState property and backing struct.
  var currentRotation: Angle {
    
    get {
      return wheelState.currentRotation
    }
    
    set(newRotation) {
      wheelState   = WheelState( currentRotation: newRotation,
                                previousRotation: newRotation,
                               previousDirection: .Clockwise)
      self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
    }
  }

  // See: The UIControl methods handling the touches to understand userState
  //      beginTrackingWithTouch(_,withEvent:)
  //      continueTrackingWithTouch(_,withEvent:)
  //      endTrackingWithTouch(_,withEvent:)
  var userState   = WheelInteractionState()

  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
    resetRotationAngle()
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupViews()
    resetRotationAngle()
  }
  
  func setupViews() {
    wheelView.userInteractionEnabled = false
    self.addSubview(wheelView)
    
    self.setTranslatesAutoresizingMaskIntoConstraints(false)
    wheelView.setTranslatesAutoresizingMaskIntoConstraints(false)
    
    
    // constraints
    let viewsDictionary = ["wheelView":wheelView]
    
    //position constraints
    let view_constraint_H:[AnyObject] =
    NSLayoutConstraint.constraintsWithVisualFormat( "H:|[wheelView]|",
                                           options: NSLayoutFormatOptions(0),
                                           metrics: nil,
                                             views: viewsDictionary)
    
    let view_constraint_V:[AnyObject] =
    NSLayoutConstraint.constraintsWithVisualFormat( "V:|[wheelView]|",
                                           options: NSLayoutFormatOptions(0),
                                           metrics: nil,
                                             views: viewsDictionary)
    
    self.addConstraints(view_constraint_H)
    self.addConstraints(view_constraint_V)
  }

  
  
  func resetRotationAngle() {
    startingRotation = internalRotationOffset
    currentAngle     = angleFromRotation(startingRotation)
    currentRotation  = startingRotation
  }
  
  
  
  // MARK: -
  // MARK: UIControl methods handling the touches
  override func beginTrackingWithTouch(touch: UITouch,
                             withEvent event: UIEvent) -> Bool {
      
    if touchRegion(touch) == .Center {
      return false  // Ends current touches to the control
    }
                            
    Animation.removeAllAnimations(wheelView.layer)
                            
    // Clear and set state at the beginning of the users rotation
    userState                    = WheelInteractionState()
    userState.currently          = .Interacting
    userState.initialTransform   = wheelView.transform
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
  
  func beginAndContinueTrackingWithTouch(touch: UITouch,
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
    
    // TODO: try to replace CGAffineTransformRotate() with CGAffineTransformMakeRotation()
    //       If so, use currentAngle = userState.initialRotation + angleDifference
    //       and remove initialTransform from userState.
    let t = CGAffineTransformRotate( userState.initialTransform, angleDifference.cgRadians )
    wheelView.transform = t
    setRotationUsingAngle(userState.initialRotation + angleDifference)
                                        
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

    case .CurrentRotation:
      if let snapToRotation = snapToRotation {
        animateToRotation(snapToRotation)
        self.snapToRotation = nil
      }
      
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
    userState = WheelInteractionState()
    
  }
  // TODO: Does cancelTrackingWithEvent need to be implimented?
//  override func cancelTrackingWithEvent(event: UIEvent?) {
//    
//  }

  // MARK: -
  // MARK: Animation
  
//    func animateToRotation(rotation: Angle) {
//        Animation.removeAllAnimations(wheelView.layer)
//        let currentRotation = self.currentRotation
//
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
    
  func animateToRotation(rotation: Angle) { // in module, make public //
    wheelState.targetRotation = rotation
    
    
    func speedUpDurationByDistance(duration: CGFloat) -> CGFloat {
      let durationDistanceFactor = CGFloat(1)
      return log((duration * durationDistanceFactor) + 1) / durationDistanceFactor
    }
    
    Animation.removeAllAnimations(wheelView.layer)
    let durationPerRadian = CGFloat(0.25)
    let totalAngularDistance = abs(currentRotation - rotation)
    let baseDuration = totalAngularDistance.cgRadians * durationPerRadian
    let totalDuration = speedUpDurationByDistance(baseDuration)
    let timing = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    
    let rotate = BasicAnimation(duration: totalDuration, timingFunction: timing)
    rotate.property = AnimatableProperty(name: kPOPLayerRotation)
    rotate.fromValue = currentRotation.cgRadians
    rotate.toValue   = rotation.cgRadians
    rotate.name = "Basic Rotation"
    rotate.delegate = self
    rotate.completionBlock = { anim, finished in
      if finished {
        self.currentAngle    = self.angleFromRotation(rotation)
        self.currentRotation = rotation
        self.wheelState.targetRotation = nil
      }
    }
    
    Animation.removeAllAnimations(wheelView.layer)
    Animation.addAnimation( rotate,
                       key: rotate.property.name,
                       obj: wheelView.layer)
  }
  
  
  func basicRotationAnimation(#from: Angle,
                                 to: Angle,
                           duration: CGFloat,
                         completion: (Animation, Bool)->()) {
                          
    let rotate = BasicAnimation(duration: duration)
    rotate.property  = AnimatableProperty(name: kPOPLayerRotation)
    rotate.fromValue = from.cgRadians
    rotate.toValue   =   to.cgRadians
    rotate.name = "Basic Rotation"
    rotate.delegate = self
    Animation.removeAllAnimations(wheelView.layer)
    Animation.addAnimation( rotate,
                       key: rotate.property.name,
                       obj: wheelView.layer)
    
  }

  
  func springRotationAnimation(#from: Angle, to: Angle) {
    
    let spring = SpringAnimation( tension: 1000,
                        friction: 30,
                            mass: 1)
    spring.property  = AnimatableProperty(name: kPOPLayerRotation)
    spring.fromValue = from.cgRadians
    spring.toValue   =   to.cgRadians
    spring.name = "Spring Rotation"
    spring.delegate = self
    spring.completionBlock = { anim, finished in
      if finished {
        self.currentAngle = self.angleFromRotation(to)
        self.setRotationUsingAngle(to)
        self.wheelState.targetRotation = nil
      }
    }
    Animation.removeAllAnimations(wheelView.layer)
    Animation.addAnimation( spring,
                       key: spring.property.name,
                       obj: wheelView.layer)
  }
  
  func pop_animationDidApply(anim: Animation!) {
    let angle = angleFromRotation(wheelState.previousRotation)
    let angleDifference = currentAngle - angle
    self.setRotationUsingAngle(currentRotation + angleDifference)
  }
  
//  func test() {
//    let step1 = currentRotation
//    let step2 = maxRotation
//    let step3 = maxRotation
//    
//    let rotate = BasicAnimation(duration: 2.0,
//      timingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn))
//    rotate.property = AnimatableProperty(name: kPOPLayerRotation)
//    rotate.fromValue = step1
//    rotate.toValue = step2
//    rotate.name = "Basic Rotation"
//    rotate.delegate = self
//    rotate.completionBlock = {anim, finsihed in
//      if finsihed {
//        let spring = SpringAnimation( tension: 100,
//                                     friction: 15,
//                                         mass: 1)
//        spring.property = AnimatableProperty(name: kPOPLayerRotation)
//        spring.fromValue = step2
//        spring.toValue = step3
//        spring.name = "Spring Rotation"
//        spring.delegate = self
//        Animation.addAnimation( spring,
//                           key: spring.property.name,
//                           obj: self.wheelView.layer)
//      }
//    }
//    Animation.addAnimation( rotate,
//                       key: rotate.property.name,
//                       obj: wheelView.layer)
//  }


  
  // MARK: Wheel State
  func setRotationUsingAngle(angle: Angle) {
      let newRotation = rotationUsingAngle( angle, AndWheelState: wheelState)
      
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
      self.sendActionsForControlEvents(UIControlEvents.ValueChanged)

  }
  
  // MARK: Wheel State - during user interaction.
  func rotationUsingAngle(angle: Angle,
       AndWheelState wheelState: WheelState) -> Angle {
                
      // This method is a hack!  This class is based on the idea that the
      // accumulated rotation angle (in radians) can be known.
      // At the time of this method, only the absolute angle from -3.14 to 3.14
      // can be determined. Unless another API is pointed out, this method
      // is used to make a best guess on tracking the accumulated rotations
      // of the wheel as it passes over the dicontinuity of this absolute angle
      // returned from the affine transform.
                
      // In various conditions, this algorithm breaks down and can not
      // determin the correct accumulated rotation.  It returns the last known
      // good state in the hopes that the next evaluation can figure it out.
                
      // Worce: execptionally fast rotations from the user or animation could
      // create overly large jumps between evaluations may produce the wrong 
      // guess.
        
      // During user interaction, this works. The angle difference from the
      // initial touch is recalculated each time, so ONLY the final evaluation
      // of this method, when touch ends, is used to keep the rotation in sync
      // with the current absolute angle.
                
      // During animations, it is best to use the expected end state of the
      // animation to set the currentRotation property to the expected value,
      // (or more precicly, the wheelState property holding backing struct)
      // overriding the accumulated changes made throughout the animation
                      
      let rotationCountFromZero = Int(abs(angle / Revolution.full))
      let tooManyTries          = rotationCountFromZero + 2
      
      var rotation = angle
      
      var difference = abs(wheelState.currentRotation - rotation)
      var previousDifference = difference
      
      // When rotating over the dicontinuity between the -3.14 and 3.14 angles,
      // we need to figure out what to add/substract from rotation to keep
      // incrementing the rotation in the correct direction
      var addOrSubtract = true
      var tries: [String] = []
                
      // TODO: Test how close to a full circle the difference can be compared to.
      //       the closer to 2 * M_PI we get, the less room for problems during
      //       fast rotations.
      while difference > Revolution.threeQuarter {
        if difference >= previousDifference {
          addOrSubtract = !addOrSubtract
        }
        if addOrSubtract {
          rotation -= Revolution.full
          tries.append("Rotation After Adding:      \(rotation) d:\(difference)")
        } else {
          rotation += Revolution.full
          tries.append("Rotation After Subtracting: \(rotation) d:\(difference)")
        }
        previousDifference = difference
        difference = abs(wheelState.currentRotation - rotation)
        
        // The algorithm has gone all wrong.
        // This is a safty to break out of the loop
        // and continue on with the previously saved state
        if tries.count > tooManyTries {
          rotation = wheelState.currentRotation
          //NSLog("Error: WheelControl could not calculate total rotation when passing over the discontinuity. Tried \(tries.count) times.")
          //for try in tries {
          //  NSLog(try)
          //}
          break // break out of the while loop
        }
      }
      
      return rotation
  }

  func angleDifferenceUsing(touch: UITouch) -> Angle {
    
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
  
  
  func directionsToDampenUsingAngle(angle: Angle) -> DampenDirection {

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
    let rotation = rotationUsingAngle(angle, AndWheelState: wheelState)
    
    
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
  func angleDifferenceBetweenTouch( touch: UITouch,
                           AndAngle angle: Angle) -> Angle {
      let touchAngle = angleAtTouch(touch)
      var angleDifference = angle - touchAngle
      
      // Notice the angleDifference is flipped to negitive
      let result = -angleDifference
      
      return result
  }
  
  func dampenClockwiseAngleDifference(var angle: Angle,
                     startingAtAngle startAngle: Angle) -> Angle {
    angle -= startAngle

    // To prevent NaN result assume negitive angles are still positive by
    // adding a full 2 radians to the angle while it is negitive. This does not
    // allow for beyond full 360° rotations, but works up to 360° before it
    // snaps back. dampening infinately rotations would require tracking 
    // previous angle.
    while angle <= 0 {
      angle += Revolution.full
    }
    
    let factor = Angle(rotationDampeningFactor)
    angle  = (log((angle * factor) + 1) / factor)
    angle += startAngle

    return angle
  }
  
  func dampenCounterClockwiseAngleDifference(var angle: Angle,
                                    startingAtAngle startAngle: Angle) -> Angle {
                                      
    angle = -angle
    angle = dampenClockwiseAngleDifference(angle, startingAtAngle: -startAngle)
    angle = -angle
                                      
    return angle
  }
  
    // MARK: UITouch Helpers
  func touchPointWithTouch(touch: UITouch) -> CGPoint {
    return touch.locationInView(self)
  }
  
  func angleAtTouch(touch: UITouch) -> Angle {
    let touchPoint = touchPointWithTouch(touch)
    return angleAtTouchPoint(touchPoint)
  }
  
  
  func angleAtTouchPoint(touchPoint: CGPoint) -> Angle {
    let dx = touchPoint.x - wheelView.center.x
    let dy = touchPoint.y - wheelView.center.y
    var angle = Angle(atan2(dy,dx))
    
    // Somewhere in the rotation of the wheelView will be a discontinuity
    // where the angle flips from -3.14 to 3.14 or  back.  This adgustment
    // places that point in negitive Y.
    if angle >= Revolution.quarter {
      angle = angle - Revolution.full
    }
    return angle
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
  
  func touchRegion(touch: UITouch) -> WheelRegion {
    
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
  func angleFromRotation(rotation: Angle) -> Angle {
    var angle = rotation
    
    if angle >  Revolution.half {
      angle += Revolution.half
      let totalRotations = floor(angle / Revolution.full)
      angle  = angle - (Revolution.full * totalRotations)
      angle -= Revolution.half
    }
    
    if angle < -Revolution.half {
      angle -= Revolution.half
      let totalRotations = floor(abs(angle) / Revolution.full)
      angle  = angle + (Revolution.full * totalRotations)
      angle += Revolution.half
    }
    
    return angle
  }
  
  
  func normalizAngle(var angle: Angle) -> Angle {
    let positiveHalfCircle =  Revolution.half
    let negitiveHalfCircle = -Revolution.half
    
    while angle > positiveHalfCircle || angle < negitiveHalfCircle {
      if angle > positiveHalfCircle {
        angle -= Revolution.full
      }
      if angle < negitiveHalfCircle {
        angle += Revolution.full
      }
    }
    return angle
  }

  func angleFromTransform(transform: CGAffineTransform) -> Angle {
    let b = transform.b
    let a = transform.a
    let angle = atan2(b, a)
    
    return Angle(angle)
  }
  
}