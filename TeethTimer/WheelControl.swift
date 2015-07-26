// MARK: - WheelControl Summery

// Wheel Control
// 
//               The public API to WheelControl rotation value is set and get
//               using the rotation property.
//               This is never referenced internally.
//
//               Instead two properties are used:
//
//               currentAngle    - A convenience property to the view transform
//               currentRotation - convenience property to RotationState.current
//
// The difference between an angle and rotation is:
//
//    angle    - Ranges from -π to π
//
//
//    rotation - Has no theoretical min and max.
//               Rotation may be used to notate the absolute number
//               of complete rotations around the wheel.
//               Rotation acculmulates in each direction where the angle
//               wraps around when greater than -π or less than π.
//
//               i.e. (in radians):
//               angle    - 0.0   1.0   2.0   3.0  -2.28 -1.28 -0.28  0.71  1.71
//               rotation - 0.0   1.0   2.0   3.0   4.00  5.00  6.00  7.00  8.00
//
//    currentAngle & currentRotation:
//               These properties are independant,  They are related, but if one
//               is modified, the other is not automaticly kept in sync.  That
//               must be done by the internal developer. rotation DOES set
//               both properties, and that is why it is the only public property
//               for working with the wheel position.
//
//               The control only fires the ValueChange event when rotationState
//               is modified (including when setting currentRotation).





import UIKit

// MARK: -
// MARK: - WheelControl Class
final class WheelControl: UIControl, AnimationDelegate  {
  
  // MARK: Properties
  // Configure WheelControl
  var centerCircle  = CGFloat(10.0)
  let wheelView     = UIView()
  
  // Configure Dampening Properties
  var dampenClockwise          = false
  var dampenCounterClockwise   = false
  
  // Set a rotation to snap to after user touch ends
  var snapToRotation: Rotation?

  // How strong should the users rotation be dampened as they
  // rotate past the allowed point
  var rotationDampeningFactor  = CGFloat(5)

  // The data of WheelControl
  // Do NOT use this internally.
  // This is the only interface for getting the rotation value for this control.
  // Externally set the data for this control with this property or 
  //                                                animateToRotation()
  var rotation: Rotation {
    get {
      return currentRotation
    }
    set(newRotation) {
      currentAngle    = Angle(newRotation)
      currentRotation =       newRotation
    }
  }

  // The min and max rotations where user rotation becomes dampened (slowed)
  var minimumRotation: Rotation? {
    didSet{
      let msg = "minimumRotation must be less than or equal to rotation."
      assert(currentRotation >= minimumRotation, msg)
    }
  }
  
  var maximumRotation: Rotation? {
    didSet{
      let msg = "maximumRotation must be less than or equal to rotation."
      assert(currentRotation <= maximumRotation, msg)
    }
  }
  
  
  // If the Wheel Control has a minimum and maximum rotation set,
  // percentageRemaining will return the remaining portion as a percentage
  var percentageRemaining: CGFloat? {
    get {
      var percentageRemaining: CGFloat?
      if let min = minimumRotation,
             max = maximumRotation {
        percentageRemaining = percentValue( CGFloat(rotation),
                              isBetweenLow: CGFloat(min),
                                   AndHigh: CGFloat(max))
      }
      return percentageRemaining
    }
  }
  
  // MARK: Convenience calculated properties
  var animationState: AnimatedMotion {
    let animations = Animation.animations(wheelView.layer)
    if animations.count == 0 {
      return .AtRest
    } else {
      return .AnimationInMotion
    }
  }
  
  var backgroundView: UIView {
    return self
  }
  
  var outsideCircle: CGFloat {
    return wheelView.bounds.height * 2
  }
    
  
  // MARK: -
  // MARK: Internal Properties
  
  // Track User interaction through out the UIControl methods
  private var userState   = InteractionState()

  // RotationState is a struct to track wheel's accumulated rotation because
  // the wheelView.transform only works within the space between -π & π
  private var rotationState = RotationState() {
    didSet(oldRotation) {
      self.sendActionsForControlEvents(.ValueChanged)
    }
  }

  // NOTE: currentAngle & currentRotation may seem so related that one
  //       should change the other.  But, that exclusive duty is left to
  //       transformToRotation() & animateToRotation() ***
  //
  //       *** via: updateRotationDuringAnimatedTransform()
  
  // currentRotation is a convenience method for retrieving
  // rotationState.current and reseting rotationState
  private var currentRotation: Rotation {
    get {
      return rotationState.current
    }
    set(newRotation) {
      rotationState = RotationState( current: newRotation,
                                    previous: newRotation)
    }
  }

  // currentAngle is a convenience method for setting and retrieving
  // the rotation from wheelView.transform.
  private var currentAngle: Angle {
    get {
      return angleFromTransform(wheelView.transform)
    }
    set(newAngle) {
      wheelView.transform = CGAffineTransformMakeRotation(CGFloat(newAngle))
    }
  }
  
  
  // MARK:
  // MARK: Initialization
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
    currentRotation = Rotation(0.0)
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupViews()
    currentRotation = Rotation(0.0)
  }

  private func setupViews() {
    wheelView.userInteractionEnabled = false
    self.addSubview(wheelView)
    
    self.setTranslatesAutoresizingMaskIntoConstraints(false)
    wheelView.setTranslatesAutoresizingMaskIntoConstraints(false)
    
    
    // constraints
    let viewsDictionary = ["wheelView":wheelView]
    
    // position constraints
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

  
  
  // MARK: -
  // MARK: UIControl methods handling the touches
  override func beginTrackingWithTouch(touch: UITouch,
                             withEvent event: UIEvent) -> Bool {
      
    switch touchRegion(touch) {
    case .Off,
         .Center:
      return false  // Ends current touches to the control
    case .On:
      break // continueTrackingWithTouch
    }
                            
    Animation.removeAllAnimations(wheelView.layer)
                            
    // Clear and set state at the beginning of the users rotation
    userState                    = InteractionState()
    userState.currently          = .Interacting
    userState.initialRotation    = currentRotation
    userState.initialTouchAngle  = angleAtTouch(touch)
    
    if let min = minimumRotation {
      userState.minDampenRotation   = -(currentRotation - min)
    }
    if let max = maximumRotation {
      userState.maxDampenRotation   =   max - currentRotation
    }
    
    return beginAndContinueTrackingWithTouch( touch, withEvent: event)
  }
  
  //
  override func continueTrackingWithTouch(touch: UITouch,
                                withEvent event: UIEvent) -> Bool {
      
    return beginAndContinueTrackingWithTouch( touch, withEvent: event)
  }
  
  //
  private func beginAndContinueTrackingWithTouch(touch: UITouch,
                               withEvent event: UIEvent) -> Bool {
    switch touchRegion(touch) {
    case .Off:
        self.sendActionsForControlEvents(.TouchDragOutside)
        self.sendActionsForControlEvents(.TouchDragExit)
        endTrackingWithTouch(touch, withEvent: event)
      return false  // Ends current touches to the control
    case .Center:
        self.sendActionsForControlEvents(.TouchDragExit)
        endTrackingWithTouch(touch, withEvent: event)
      return false  // Ends current touches to the control
    case .On:
      break // continueTrackingWithTouch
    }
    
    transformToTouch(touch)
    
    return true
  }
  
  //
  override func endTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) {
    endUserInteraction()
  }

  //
  override func cancelTrackingWithEvent(event: UIEvent?) {
    endUserInteraction()
  }

  //
  private func endUserInteraction() {
    // User interaction has ended, but userState is
    // still used through out this method.
    userState.currently = .NotInteracting
    
    switch userState.snapTo {
    case .InitialRotation:
      animateToRotation(userState.initialRotation)
      
    case .CurrentRotation:
      if let snapToRotation = snapToRotation {
        animateToRotation(snapToRotation)
        self.snapToRotation = .None
      }
      
    case .MinRotation:
      if let rotation = minimumRotation {
        animateToRotation(rotation)
      }
    case .MaxRotation:
      if let rotation = maximumRotation {
        animateToRotation(rotation)
      }
    }
    
    // User rotation has ended.  Forget the state.
    userState = InteractionState()
  }
  
  // MARK: -
  // MARK: Setting and calculating the Rotation
  private func transformToTouch(touch: UITouch) {
    let rotation = userState.initialRotation + angleDifferenceUsing(touch)
    transformToRotation(rotation)
  }
  
  // This method updates the rotationState is responce to the wheel.transform
  // changing during animation.
  private func updateRotationDuringAnimatedTransform() {
    
    // By only setting currentRotation and not doing transformToRotation()
    // the public property, rotation, will be updated but not alter the actual
    // transform of the wheel.
    self.currentRotation = calculateRotationFromPreviousAngle()
  }

  // Call this to get the rotation of the wheel when it is transformed
  // and you don't have any other way to determine the rotation.
  private func calculateRotationFromPreviousAngle() -> Rotation {
    let angleDifference = currentAngle - rotationState.previousAngle
    return currentRotation + angleDifference
  }
  
  // updates currentRotation and transforms wheel via currentAngle
  private func transformToRotation(rotation: Rotation) {
    incrementToRotation(rotation)
    currentAngle = Angle(rotation)
  }

  // Updates the currentRotation calculated property by changing
  // the rotationState backing property.
  private func incrementToRotation(rotation: Rotation) {
    rotationState = RotationState( current: rotation,
                                  previous: rotationState.current)
   }

  // Calculate angleDifference, including dampening in either direction
  private func angleDifferenceUsing(touch: UITouch) -> Rotation {
    
    let angleDiff = angleDifferenceBetweenTouch( touch,
                                       AndAngle: userState.initialTouchAngle)
    
    var dampenedDiff = angleDiff
    
    let undampenedNewRotation = userState.initialRotation + angleDiff
    var dampenDirection = directionsToDampenUsingRotation(undampenedNewRotation)
    
    switch dampenDirection.clockwise {
      case .atRotation(let startRotation):
        dampenedDiff = dampenClockwiseRotationDifference( angleDiff,
                                      startingAtRotation: startRotation)
      case .no:
        break
    }

    switch dampenDirection.counterClockwise {
      case .atRotation(let startRotation):
        dampenedDiff = dampenCounterClockwiseRotationDifference( angleDiff,
                                             startingAtRotation: startRotation)
      case .no:
        break
    }
    
    return dampenedDiff
  }
  
  
  // Build the struct of clockwise & counter-clockwise dampening angles
  private func directionsToDampenUsingRotation(rotation: Rotation) -> DampenDirection {

    // Each change in the touch angle of the WheelControl calls
    // directionsToDampenUsingAngle()  At each check, assume that
    // the userState.snapTo should be .CurrentRotation until the angle
    // is evaluated.
    userState.snapTo = .CurrentRotation
    
    // Assume also that their is no dampening to be done at this angle
    // until it is evaluated below. New DampenDirection structs are '.no' in
    // both directions.
    var dampenRotation  = DampenDirection()
  
    // Check for the optional minimumRotation & maximumRotation properties.
    // If they exist, the wheel is limited in how far it may rotate.
    // We need to pass back via the dampenRotation return variable,
    // at what angle to start dampening the rotation.
    // This number (passed in the .atRotation() enum) is the difference in the
    // angle between the user begining to rotate, and the angle to start 
    // dampening.
    
    // Also set the userState to snapTo what possition after the 
    // user interaction is complete.
    
    if let min = minimumRotation {
      if rotation < min {
        dampenRotation.counterClockwise = .atRotation(userState.minDampenRotation)
        userState.snapTo = .MinRotation
      }
    }
    if let max = maximumRotation {
      if rotation > max {
        dampenRotation.clockwise = .atRotation(userState.maxDampenRotation)
        userState.snapTo = .MaxRotation
      }
    }
    
    
    // If the dampenClockwise or dampenCounterClockwise properties are set,
    // they override the either minimumRotation & maximumRotation and set the
    // dampening to begin imediately on user interaction.
    // (Use one or the other to prevent users from turning the wheel that 
    // direction)
    if rotation > userState.initialRotation && dampenClockwise {
      dampenRotation.clockwise = .atRotation(0.0)
      userState.snapTo = .InitialRotation
    }
    
    if rotation < userState.initialRotation && dampenCounterClockwise {
      dampenRotation.counterClockwise = .atRotation(0.0)
      userState.snapTo = .InitialRotation
    }
    
    return dampenRotation
  }
  
  // MARK:
  // MARK: Wheel State Helpers
  private func angleDifferenceBetweenTouch( touch: UITouch,
                           AndAngle angle: Angle) -> Rotation {
                            
      let msg = "angle \(angle) in angleDifferenceBetweenTouch:AndAngle: produced a number ouside of a legal Angle"
      assert(isWithinAngleLimits(angle.value), msg)
                            
      let touchAngle = angleAtTouch(touch)
      var angleDifference = Rotation(angle - touchAngle)
      
      // Notice the angleDifference is flipped to negitive
      let result = -angleDifference
      
      return result
  }
  
  private func dampenClockwiseRotationDifference(var rotation: Rotation,
                     startingAtRotation startRotation: Rotation) -> Rotation {
    
    rotation -= startRotation

    // To prevent NaN result assume negitive angles are still positive by
    // adding a full 2 radians to the angle while it is negitive. This does not
    // allow for beyond full 360° rotations, but works up to 360° before it
    // snaps back. dampening infinately rotations would require tracking 
    // previous angle.
    while rotation <= 0 {
      rotation += Rotation.tau
    }
    
    let factor = Rotation(rotationDampeningFactor)
    rotation  = (log((rotation * factor) + 1) / factor)
    rotation += startRotation

    return rotation
  }
  
  private func dampenCounterClockwiseRotationDifference(var rotation: Rotation,
                            startingAtRotation startRotation: Rotation) -> Rotation {
                                      
    rotation = -rotation
    rotation = dampenClockwiseRotationDifference(rotation, startingAtRotation: -startRotation)
    rotation = -rotation
                                      
    return rotation
  }
  
  
  // MARK: UITouch Helpers
  private func touchPointWithTouch(touch: UITouch) -> CGPoint {
    return touch.locationInView(self)
  }
  
  private func angleAtTouch(touch: UITouch) -> Angle {
    let touchPoint = touchPointWithTouch(touch)
    return angleAtTouchPoint(touchPoint)
  }
  
  
  private func angleAtTouchPoint(touchPoint: CGPoint) -> Angle {
    let dx = touchPoint.x - wheelView.center.x
    let dy = touchPoint.y - wheelView.center.y
    
    let tmpAngle = atan2(dy,dx)
    let msg = "touch point in angleAtTouchPoint produced a number ouside of a legal Angle"
    assert(isWithinAngleLimits(tmpAngle), msg)
    var angle = Angle(tmpAngle)
    
    // Somewhere in the rotation of the wheelView will be a discontinuity
    // where the angle flips from -π to π or  back.  This adgustment
    // places that point in negitive Y.
    if angle >= Angle.quarterCircle {
      angle = Angle(Rotation(angle) - Rotation.tau)
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
  
  private func touchRegion(touch: UITouch) -> Region {
    
    let dist = distanceFromCenterWithTouch(touch)
    var region: Region = .On
    
    if (dist < centerCircle) {
      region = .Center
    }
    if (dist > outsideCircle) {
      region = .Off
    }
    
    return region
  }
  
  // MARK: Precent Helpers
  private func percentValue(value: CGFloat,
                isBetweenLow  low: CGFloat,
                AndHigh      high: CGFloat ) -> CGFloat {
                  
      return (value - low) / (high - low)
  }
  

  // MARK: Angle Helpers
  private func angleFromTransform(transform: CGAffineTransform) -> Angle {
    let b = transform.b
    let a = transform.a
    let angle = Angle(atan2(b, a))
    
    return angle
  }
  
}







// MARK: -
// MARK: Animation Methods

extension WheelControl {
  
  // MARK: POP Animation Delegate Callback
  //       This is called continually throughout all animations.
  func pop_animationDidApply(anim: Animation!) {
    if anim != nil {
      animationDidApply(anim)
    }
  }
  
  
  func animationDidApply(anim: Animation) {
    if animationHasNotOvershotTargetRotation(anim) {
      updateRotationDuringAnimatedTransform()
    } else {
      println("Animation over shot the rotation and WeheelControl has ignored the update of the rotationState")
    }
  }
  
  
  func animationHasNotOvershotTargetRotation(anim: Animation) -> Bool {
    var hasNotOvershot = true
    let newRotation = CGFloat(calculateRotationFromPreviousAngle())
    
    if anim.isKindOfClass(BasicAnimation) {
      let basicAnim = anim as! BasicAnimation
      let from      = basicAnim.fromValue as! CGFloat
      let to        = basicAnim.toValue   as! CGFloat
      
      if to > from {
        if newRotation > to {
          hasNotOvershot = false
        }
      } else {
        if newRotation < to {
          hasNotOvershot = false
        }
      }
    }
    return hasNotOvershot
  }
  
  // MARK: -
  // MARK: Public animation API
  func animateToRotation(rotation: Rotation) {

    func speedUpDurationByDistance(duration: CGFloat) -> CGFloat {
      let durationDistanceFactor = CGFloat(1)
      return log((duration * durationDistanceFactor) + 1) / durationDistanceFactor
    }
    
    Animation.removeAllAnimations(wheelView.layer)
    let durationPerRadian = CGFloat(0.25)
    let rotationDistanceToAnimate = abs(currentRotation - rotation)
    let baseDuration = CGFloat(rotationDistanceToAnimate) * durationPerRadian
    let totalDuration = speedUpDurationByDistance(baseDuration)
    let timing = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    
    let rotate = BasicAnimation(duration: totalDuration, timingFunction: timing)
    rotate.property  = AnimatableProperty(name: kPOPLayerRotation)
    rotate.fromValue = CGFloat(currentRotation)
    rotate.toValue   = CGFloat(rotation)
    rotate.name      = "Basic Rotation"
    rotate.delegate  = self
    rotate.completionBlock = { anim, finished in
      if finished && (self.currentAngle != Angle(rotation)) {
          self.transformToRotation(rotation)
      }
    }
    
    Animation.removeAllAnimations(wheelView.layer)
    Animation.addAnimation( rotate,
      key: rotate.property.name,
      obj: wheelView.layer)
  }
  
  // MARK:
  // MARK: Unused methods as examples for different different types of animation
  private func basicRotationAnimation(#from: Rotation,
    to: Rotation,
    duration: CGFloat,
    completion: (Animation, Bool)->()) {
      
      let rotate = BasicAnimation(duration: duration)
      rotate.property  = AnimatableProperty(name: kPOPLayerRotation)
      rotate.fromValue = CGFloat(from)
      rotate.toValue   = CGFloat(to)
      rotate.name = "Basic Rotation"
      rotate.delegate = self
      Animation.removeAllAnimations(wheelView.layer)
      Animation.addAnimation( rotate,
        key: rotate.property.name,
        obj: wheelView.layer)
      
  }
  
  
  private func springRotationAnimation(#from: Rotation, to: Rotation) {
    
    let spring = SpringAnimation( tension: 1000,
      friction: 30,
      mass: 1)
    spring.property  = AnimatableProperty(name: kPOPLayerRotation)
    spring.fromValue = CGFloat(from)
    spring.toValue   = CGFloat(to)
    spring.name = "Spring Rotation"
    spring.delegate = self
    spring.completionBlock = { anim, finished in
      if finished {
        self.transformToRotation(to)
      }
    }
    Animation.removeAllAnimations(wheelView.layer)
    Animation.addAnimation( spring,
      key: spring.property.name,
      obj: wheelView.layer)
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
  
  
}