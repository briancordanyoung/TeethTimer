// MARK: - WheelControl Summery

// Wheel Control
// 
//               The public API to WheelControl value (position) is set and get
//               using the rotation property.
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
//    rotation - Has no theoretical min and max.
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
//               must be done by the internal developer. rotation DOES set
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
// MARK: - WheelControl Class
final class WheelControl: UIControl, AnimationDelegate  {

  // The data of WheelControl
  // Do not use this internally.
  // This is the only interface for getting the data for this control.
  // Externally set the data for this control with this property or 
  //                                                animateToRotation()
  var rotation: Rotation {  // in module, make public //
    get {
      return currentRotation
    }
    set(newRotationAngle) {
      currentAngle    = Angle(newRotationAngle)
      currentRotation =       newRotationAngle
    }
  }
  
  var percentageRemaining: CGFloat? {
    get {
      var percentageRemaining: CGFloat?
      if let min = minimumRotation, max = maximumRotation {
        let current = rotation
        percentageRemaining = percentValue( current.cgRadians,
                         isBetweenLow: min.cgRadians,
                              AndHigh: max.cgRadians)
      }
      return percentageRemaining
    }
  }
  
  func percentValue(value: CGFloat,
        isBetweenLow  low: CGFloat,
        AndHigh      high: CGFloat ) -> CGFloat {
      return (value - low) / (high - low)
  }
  
  var targetRotation: Rotation {  // in module, make public //
      var targetRotation = rotation
      if let target = rotationState.target {
        targetRotation = target
      }
      return targetRotation
  }
  
  var animationState: AnimatedMotion {
    
    let animations = Animation.animations(wheelView.layer)
    
    let state: AnimatedMotion
    if animations.count == 0 {
      state = .AtRest
    } else {
      state = .AnimationInMotion
    }
    
    return state
  }
  
  // Configure WheelControl
  var centerCircle:      CGFloat = 10.0
  var startingRotation           =  Rotation(0.0)
  let wheelView                  = UIView()
  var backgroundView: UIView {
    return self
  }


  var snapToRotation: Rotation?

  // Configure Dampening Properties
  var dampenClockwise          = false
  var dampenCounterClockwise   = false
  var minimumRotation: Rotation? {
    get {
      return minRotation
    }
    set(newMinRotation) {
      if let newMinRotation = newMinRotation {
        let newMinRotationWithOffset = newMinRotation

        let msg = "minRotation must be less than or equal to rotation."
        assert(currentRotation >= newMinRotationWithOffset, msg)
        
        minRotation = newMinRotationWithOffset
      } else {
        minRotation = nil
      }
    }
  }
  var maximumRotation: Rotation? {
    get {
      return maxRotation
    }
    set(newMaxRotation) {
      if let newMaxRotation = newMaxRotation {
        let newMaxRotationWithOffset = newMaxRotation
        
        let msg = "maxRotation must be greater than or equal to rotation."
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
  
  var minRotation: Rotation?
  var maxRotation: Rotation?
  
  
  // The method rotationUsingAngle(AndRotationState:) is a hack to try and figure
  // out what the currentRotation should be.  That method has less problems when
  // the rotation is greater than 0.  This offset is used to internally add
  // to the currentRotation.  The public properties that are used outside this
  // class will add/subtract this offset when set/get.
  
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
  
  // See: rotationFromAngle(_,AndRotationState:) for and explination of the
  // the rotationState property and struct.
  var rotationState = RotationState()

  // See: rotationUseingAngle() for and explination of the
  // the currentRotation property, rotationState property and backing struct.
  var currentRotation: Rotation {
    get {
      return rotationState.current
    }
    set(newRotation) {
      rotationState = RotationState( current: newRotation,
                                    previous: newRotation,
                                   direction: .Clockwise)
      self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
    }
  }

  // See: The UIControl methods handling the touches to understand userState
  //      beginTrackingWithTouch(_,withEvent:)
  //      continueTrackingWithTouch(_,withEvent:)
  //      endTrackingWithTouch(_,withEvent:)
  var userState   = InteractionState()

  
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

  func resetRotationAngle() {
    startingRotation = 0.0
    currentAngle     = Angle(startingRotation)
    currentRotation  = startingRotation
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

  
  
  
  
  // MARK: -
  // MARK: UIControl methods handling the touches
  override func beginTrackingWithTouch(touch: UITouch,
                             withEvent event: UIEvent) -> Bool {
      
    if touchRegion(touch) == .Center {
      return false  // Ends current touches to the control
    }
                            
    Animation.removeAllAnimations(wheelView.layer)
                            
    // Clear and set state at the beginning of the users rotation
    userState                    = InteractionState()
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
    setRotation(userState.initialRotation + angleDifference)
                                        
    self.sendActionsForControlEvents(UIControlEvents.TouchDragInside)
    
    return true
  }
  
  override func endTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) {
    endUserInteraction()
  }

  override func cancelTrackingWithEvent(event: UIEvent?) {
    endUserInteraction()
  }

  func endUserInteraction() {
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
    userState = InteractionState()
  }
  
  
  func setRotation(rotation: Rotation) {
    let newDirection: Direction
    if rotation > rotationState.current {
      newDirection = .Clockwise
    } else if rotation < rotationState.current {
      newDirection = .CounterClockwise
    } else {
      newDirection = rotationState.direction
    }
    
    rotationState = RotationState( current: rotation,
                         previous: rotationState.current,
                        direction: newDirection)
    self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
  }

  
  // MARK: Wheel State - during user interaction.
  func angleDifferenceUsing(touch: UITouch) -> Rotation {
    
    let angleDiff = angleDifferenceBetweenTouch( touch,
                                       AndAngle: userState.initialTouchAngle)
    
    var dampenedDiff = angleDiff
    
    // TODO: Should undampenedNewRotation be feed in to directionsToDampenUsingAngle()?
    //       seems like it should be userState.initialAngle + angleDiff
    //       but that doesn't work.
    let undampenedNewRotation = userState.initialRotation + angleDiff
    
    var dampen = directionsToDampenUsingRotation(undampenedNewRotation)
    
    switch dampen.clockwise {
      case .atRotation(let startRotation):
        dampenedDiff = dampenClockwiseRotationDifference( angleDiff,
                                      startingAtRotation: startRotation)
      case .no:
        break
    }

    switch dampen.counterClockwise {
      case .atRotation(let startRotation):
        dampenedDiff = dampenCounterClockwiseRotationDifference( angleDiff,
                                             startingAtRotation: startRotation)
      case .no:
        break
    }
    
    return dampenedDiff
  }
  
  
  func directionsToDampenUsingRotation(rotation: Rotation) -> DampenDirection {

    // Each change in the touch angle of the WheelControl calls
    // directionsToDampenUsingAngle()  At each check, assume that
    // the userState.snapTo should be .CurrentRotation until the angle
    // is evaluated.
    userState.snapTo = .CurrentRotation
    
    // Assume also that their is no dampening to be done at this angle
    // until it is evaluated below. New DampenDirection structs are '.no' in
    // both directions.
    var dampenRotation  = DampenDirection()
  
    // Check for the optional minRotation & maxRotation properties.
    // If they exist, the wheel is limited in how far it may rotate.
    // We need to pass back via the dampenRotation varriable, at what angle to
    // start dampening the rotation.  This number (passed in the .atRotation() enum)
    // is the difference in the angle between the user begining to rotate,
    // and the angle to start dampening.
    
    // Also set the userState to snapTo what possition after the 
    // user interaction is complete.
    
    if let min = minRotation {
      if rotation < min {
        dampenRotation.counterClockwise = .atRotation(userState.minDampenAngle)
        userState.snapTo = .MinRotation
      }
    }
    if let max = maxRotation {
      if rotation > max {
        dampenRotation.clockwise = .atRotation(userState.maxDampenAngle)
        userState.snapTo = .MaxRotation
      }
    }
    
    
    // If the dampenClockwise or dampenCounterClockwise properties are set,
    // they override the either minRotation & maxRotation and set the
    // dampening to begin imediately on user interaction.
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
  
    // MARK: Wheel State Helpers
  func angleDifferenceBetweenTouch( touch: UITouch,
                           AndAngle angle: Angle) -> Rotation {
                            
      let msg = "angle \(angle) in angleDifferenceBetweenTouch:AndAngle: produced a number ouside of a legal Angle"
      assert(isWithinAngleLimits(angle.value), msg)
                            
      let touchAngle = angleAtTouch(touch)
      var angleDifference = Rotation(angle - touchAngle)
      
      // Notice the angleDifference is flipped to negitive
      let result = -angleDifference
      
      return result
  }
  
  func dampenClockwiseRotationDifference(var rotation: Rotation,
                     startingAtRotation startRotation: Rotation) -> Rotation {
    
    rotation -= startRotation

    // To prevent NaN result assume negitive angles are still positive by
    // adding a full 2 radians to the angle while it is negitive. This does not
    // allow for beyond full 360° rotations, but works up to 360° before it
    // snaps back. dampening infinately rotations would require tracking 
    // previous angle.
    while rotation <= 0 {
      rotation += Rotation.full
    }
    
    let factor = Rotation(rotationDampeningFactor)
    rotation  = (log((rotation * factor) + 1) / factor)
    rotation += startRotation

    return rotation
  }
  
  func dampenCounterClockwiseRotationDifference(var rotation: Rotation,
                            startingAtRotation startRotation: Rotation) -> Rotation {
                                      
    rotation = -rotation
    rotation = dampenClockwiseRotationDifference(rotation, startingAtRotation: -startRotation)
    rotation = -rotation
                                      
    return rotation
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
    
    let tmpAngle = atan2(dy,dx)
    let msg = "touch point in angleAtTouchPoint produced a number ouside of a legal Angle"
    assert(isWithinAngleLimits(tmpAngle), msg)
    var angle = Angle(tmpAngle)
    
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
  
  func touchRegion(touch: UITouch) -> Region {
    
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
  

  // MARK: Angle Helpers
  func angleFromTransform(transform: CGAffineTransform) -> Angle {
    let b = transform.b
    let a = transform.a
    let angle = Angle(atan2(b, a))
    
    return angle
  }
  
}