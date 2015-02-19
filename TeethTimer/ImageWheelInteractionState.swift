import CoreGraphics

enum SnapWheelTo {
    case InitialWedge
    case CurrentWedge
}

enum InteractionState {
    case Interacting
    case NotInteracting
}

class ImageWheelInteractionState {
    
    var initialTransform = CGAffineTransformMakeRotation(0)
    var initialWedge: WedgeValue = 1
    
    var initialAngle:  CGFloat  = 0.0
    var previousAngle: CGFloat  = 0.0
    
    var wheelHasFlipped360: Bool = false
    
    var currently: InteractionState  = .NotInteracting
    var direction: DirectionRotated  = .Clockwise
    var snapTo:    SnapWheelTo       = .InitialWedge
    
    init() {
        reset()
    }
    
    func reset() {
        initialTransform   = CGAffineTransformMakeRotation(0)
        initialAngle       = 0.0
        previousAngle      = 0.0
        currently          = .NotInteracting
        direction          = .Clockwise
        snapTo             = .CurrentWedge
        wheelHasFlipped360 = false
    }
    
    func initialWedgeIsNotWedge(wedgeValue: WedgeValue) -> Bool {
        return initialWedge != wedgeValue
    }

}

