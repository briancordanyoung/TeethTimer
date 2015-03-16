import CoreGraphics

enum SnapWheelTo: String, Printable {
  case InitialRotation = "InitialRotation"
  case CurrentRotation = "CurrentRotation"
  case MinRotation = "MinRotation"
  case MaxRotation = "MaxRotation"
  
  var description: String {
    return self.rawValue
  }
}

enum InteractionState: String, Printable {
  case Interacting = "Interacting"
  case NotInteracting = "NotInteracting"
  
  var description: String {
    return self.rawValue
  }
}

class ImageWheelInteractionState {
  
  var initialImage: ImageIndex = 1
  
  var initialTransform = CGAffineTransformMakeRotation(0)
  var initialTouchAngle: CGFloat = 0.0
  var initialRotation:   CGFloat = 0.0
  var maxDampenAngle:    CGFloat =  CGFloat(FLT_MAX)
  var minDampenAngle:    CGFloat = -CGFloat(FLT_MAX)
  
  var currently: InteractionState = .NotInteracting
  var snapTo:    SnapWheelTo      = .CurrentRotation
  
  init() {
    reset()
  }
  
  func reset() {
    initialTransform   = CGAffineTransformMakeRotation(0)
    initialTouchAngle  = 0.0
    initialRotation    = 0.0
    currently          = .NotInteracting
    snapTo             = .CurrentRotation
    maxDampenAngle     =  CGFloat(FLT_MAX)
    minDampenAngle     = -CGFloat(FLT_MAX)
  }
}

