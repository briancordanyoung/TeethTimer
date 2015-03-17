import CoreGraphics

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

struct WheelInteractionState {
  
  var initialTransform:  CGAffineTransform
  var initialTouchAngle: CGFloat
  var initialRotation:   CGFloat
  var maxDampenAngle:    CGFloat
  var minDampenAngle:    CGFloat
  
  var currently: InteractionState
  var snapTo:    SnapWheelTo
  
  init() {
    initialTransform   = CGAffineTransformMakeRotation(0)
    initialTouchAngle  = 0.0
    initialRotation    = 0.0
    currently          = .NotInteracting
    snapTo             = .CurrentRotation
    maxDampenAngle     =  CGFloat(FLT_MAX)
    minDampenAngle     = -CGFloat(FLT_MAX)
  }
}

