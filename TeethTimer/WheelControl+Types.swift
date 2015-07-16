import UIKit

// MARK: Various enums and structs used throughout the WheelControl Class


extension WheelControl {
  
  // MARK:
  // MARK: Tracking the Wheel Rotation

  // This is used to store the state needed to track the cumulative rotation
  // of the wheel over the course of several full rotations..
  // (more than a single full rotation, which is all that the
  //  AffineTransform of the UIView can represent)
  struct RotationState: Printable {
    let current:   Rotation
    let previous:  Rotation
    
    init() {
      current   = 0.0
      previous  = 0.0
    }
    
    init( current: Rotation,
         previous: Rotation) {
        self.current   = current
        self.previous  = previous
    }
    
    init(rotation: Rotation) {
      self.init(current: rotation,
               previous: rotation)
    }
    
    // Convenience Properties to transform the Rotation to an Angle
    var previousAngle: Angle {
      return Angle(previous)
    }
    
    var currentAngle: Angle {
      return Angle(current)
    }
    
    var description: String {
      var msg =  "Current Rotation: \(current.degrees) "
      msg    +=  "Previous Rotation: \(previous.degrees) "
      return msg
    }
  }

  // MARK:
  // MARK: Tracking the User Interaction
  // Defines if the wheel is currently under the control
  // of user interaction or not.
  enum UserInteraction: String, Printable {
    case Interacting    = "Interacting"
    case NotInteracting = "Not Interacting"
    
    var description: String {
      return self.rawValue
    }
  }
  
  // Describes what angle the wheel should snap-to when the user lets go
  enum SnapTo: String, Printable {
    case InitialRotation = "Initial Rotation"
    case CurrentRotation = "Current Rotation"
    case MinRotation     = "Minimum Rotation"
    case MaxRotation     = "Maximum Rotation"
    
    var description: String {
      return self.rawValue
    }
  }
  
  // While a user touches and drags the wheel, this tracks all state
  // used to calculate the current and final resting rotation of the wheel.

  struct InteractionState {
    
    var initialTouchAngle          = Angle(0.0)
    var initialRotation            = Rotation(0.0)
    var currently: UserInteraction = .NotInteracting
    var snapTo:    SnapTo          = .CurrentRotation
    var minDampenRotation          = -Rotation(DBL_MAX)
    var maxDampenRotation          =  Rotation(DBL_MAX)
    
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