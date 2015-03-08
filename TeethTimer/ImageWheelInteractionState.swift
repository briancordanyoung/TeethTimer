import CoreGraphics

enum SnapWheelTo {
    case InitialImage
    case CurrentImage
    case FirstImage
    case LastImage
}

enum InteractionState {
    case Interacting
    case NotInteracting
}

class ImageWheelInteractionState {
    
    var initialTransform = CGAffineTransformMakeRotation(0)
    var initialImage: ImageIndex = 1
    
    var initialAngle:  CGFloat  = 0.0
    var previousAngle: CGFloat  = 0.0
    
    var wheelHasFlipped360: Bool = false
    
    var currently: InteractionState  = .NotInteracting
    var direction: DirectionRotated  = .Clockwise
    var snapTo:    SnapWheelTo       = .CurrentImage
    
    init() {
        reset()
    }
    
    func reset() {
        initialTransform   = CGAffineTransformMakeRotation(0)
        initialAngle       = 0.0
        previousAngle      = 0.0
        currently          = .NotInteracting
        direction          = .Clockwise
        snapTo             = .CurrentImage
        wheelHasFlipped360 = false
    }
    
    func initialImageIsNotImage(image: ImageIndex) -> Bool {
        return initialImage != image
    }

}

