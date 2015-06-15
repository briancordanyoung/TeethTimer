import UIKit

// MARK: - Various enums and structs used throughout the WheelControl Class


extension WheelControl {
  
  // MARK: -
  // MARK: Tracking the Wheel Rotation
  // Which way is the wheel spinning?.
  enum Direction: String, Printable {
      case Clockwise        = "Clockwise"
      case CounterClockwise = "CounterClockwise"

      var description: String {
          return self.rawValue
      }
  }

  // This is used to store the state needed to track the cumulative rotation
  // of the wheel over the course of several full rotations..
  // (more than a single full rotation, which is all that the
  //  AffineTransform of the UIView can represent)
  struct RotationState: Printable {
    static let initialVelocity: Rotation = 0.0000001
    
    var current:   Rotation
    var previous:  Rotation
    var direction: Direction
    var target:    Rotation?
    
    init() {
      current   =  0.0
      previous  = -RotationState.initialVelocity
      direction = .Clockwise
    }
    
    init( current: Rotation,
         previous: Rotation,
        direction: Direction) {
        self.current   = current
        self.previous  = previous
        self.direction = direction
    }
    
    init(angle: Rotation) {
      self.init(current: angle,
               previous: angle - RotationState.initialVelocity,
              direction: .Clockwise)
    }

    var description: String {
      var msg =  "Current Rotation: \(current) "
      msg    +=  "Previous Rotation: \(previous) "
      msg    +=  "Previous Cirection: \(direction)"
      return msg
    }
  }

  // MARK: -
  // MARK: Tracking the User Interaction
  // Defines if the wheel is currently under the control
  // of user interaction or not.
  enum UserInteraction: String, Printable {
    case Interacting    = "Interacting"
    case NotInteracting = "NotInteracting"
    
    var description: String {
      return self.rawValue
    }
  }
  
  // Describes what angle the wheel should snap-to when the user lets go
  enum SnapTo: String, Printable {
    case InitialRotation = "InitialRotation"
    case CurrentRotation = "CurrentRotation"
    case MinRotation     = "MinRotation"
    case MaxRotation     = "MaxRotation"
    
    var description: String {
      return self.rawValue
    }
  }
  
  // While a user touches and drags the wheel, this tracks all state
  // used to calculate the current and final resting rotation of the wheel.
  struct InteractionState {
    
    var initialTransform:  CGAffineTransform
    var initialTouchAngle: Angle
    var initialRotation:   Rotation
    var maxDampenAngle:    Rotation
    var minDampenAngle:    Rotation
    
    var currently: UserInteraction
    var snapTo:    SnapTo
    
    init() {
      initialTransform   = CGAffineTransformMakeRotation(0)
      initialTouchAngle  = 0.0
      initialRotation    = 0.0
      currently          = .NotInteracting
      snapTo             = .CurrentRotation
      maxDampenAngle     =  Rotation(DBL_MAX)
      minDampenAngle     = -Rotation(DBL_MAX)
    }
  }

  
  // MARK: -
  // MARK: Tracking when to slow (dampen) the wheel while a user drags it
  // At what angle should the wheel being to dampen it's rotation
  // as a user spins the wheel, logarithmically coming to an angle
  // where the user cann't spin it further
  enum DampenAngle: Printable {
    case no
    case atRotation(Rotation)
    
    var description: String {
      switch self {
      case no:
        return "<none>"
      case atRotation(let rotation):
        return "\(rotation)"
      }
    }
  }
  
  // Track if the wheel should start dampening it's rotation while the user
  // drags it, and at what angle it should start the dampening.
  struct DampenDirection: Printable {
    var clockwise:        DampenAngle = .no
    var counterClockwise: DampenAngle = .no
    
    var description: String {
      var msg = "Dampen when angle difference reaches: \(clockwise) (Clockwise) "
      msg    += "or \(counterClockwise) (Counter Clockwise)"
      return msg
    }
  }
  
  
  // MARK: -
  // MARK: Other Enums
  
  // Is the wheel currently animated or not.
  enum AnimatedMotion: String, Printable {
    case AnimationInMotion  = "Animation In Motion"
    case AtRest             = "At Rest"
    
    var description: String {
      return self.rawValue
    }
  }
  
  // The controls UIView is broken in to 3 circular regions,
  // used primarily to handle touches.
  enum Region: String, Printable  {
    case On     = "On"
    case Off    = "Off"
    case Center = "Center"
    
    var description: String {
      return self.rawValue
    }
  }
  
  
}