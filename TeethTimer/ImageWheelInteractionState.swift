import CoreGraphics

enum SnapWheelTo {
    case WedgeBeforeInteraction
    case CurrentWedge
}

enum InteractionState {
    case Interacting
    case NotInteracting
}

class ImageWheelInteractionState {
    
    var currently: InteractionState = .NotInteracting
    var startTransform = CGAffineTransformMakeRotation(0)
    var wedgeValueBeforeTouch: WedgeValue = 1     // wedge to image?
    
    var previousAngle: CGFloat      = 0.0
    var firstTouchAngle: CGFloat    = 0.0
    var maxAngleDifference: CGFloat = 0.0
    
    var wheelHasFlipped360: Bool = false
    
    var direction: rotationDirection = .Positive
    var snapTo: SnapWheelTo = .WedgeBeforeInteraction
    
    init() {
        reset()
    }
    
    func reset() {
        currently = .NotInteracting
        snapTo = .CurrentWedge
        previousAngle   = 0.0
        firstTouchAngle = 0.0
        maxAngleDifference = 0.0
        wheelHasFlipped360 = false
        direction = .Positive
        startTransform = CGAffineTransformMakeRotation(0)
    }

}

