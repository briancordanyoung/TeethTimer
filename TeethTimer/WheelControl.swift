import UIKit

typealias ImageIndex = Int

struct WheelState {
    static let initialVelocity: CGFloat = 0.0000001

    var currentRotation: CGFloat  =  0.0
    var previousRotation: CGFloat = -initialVelocity
    var previousDirection: DirectionRotated = .Clockwise

    
    init( currentRotation: CGFloat,
         previousRotation: CGFloat,
        previousDirection: DirectionRotated) {
            self.currentRotation = currentRotation
            self.previousRotation = previousRotation
            self.previousDirection = previousDirection
    }
    
    init(angle: CGFloat) {
        self.init(currentRotation: angle,
            previousRotation: angle - WheelState.initialVelocity,
            previousDirection: .Clockwise)
    }
}

enum DirectionToRotate {
    case Clockwise
    case CounterClockwise
    case Closest
}

enum DirectionRotated {
    case Clockwise
    case CounterClockwise
}

enum Parity {
    case Even
    case Odd
}

private let halfCircle = CGFloat(M_PI)
private let fullCircle = CGFloat(M_PI) * 2
private let quarterCircle = CGFloat(M_PI) / 2
private let threeQuarterCircle = quarterCircle + halfCircle

class WheelControl: UIControl, AnimationDelegate  {

    private var container = UIView()
    private var currentAngle: CGFloat {
        get {
            return angleFromTransform(container.transform)
        }
    }
    
    var wheelState = WheelState(currentRotation: 0.0,
                               previousRotation:-0.0001,
                              previousDirection: .Clockwise)

    var currentRotation: CGFloat {
        
        get {
            return self.wheelState.currentRotation
        }
        
        set(newRotation) {
            let rotationsFromZero = Int(abs(newRotation / fullCircle))
            let tooManyTries      = rotationsFromZero + 2
            
            let ws = wheelState
            
            var adjustedRotation = newRotation

            var difference = abs(ws.currentRotation - adjustedRotation)
            var previousDifference = difference
            
            // When rotating over the dicontinuity between
            // the -3.14 and 3.14 angles, we need to figure out
            // the what to add/substract from adjustedRotation to
            // keep incrementing adjustedRotation in the right direction
            var addOrSubtract = true
            var tries: [String] = []
            while difference > threeQuarterCircle {
                if difference >= previousDifference {
                    addOrSubtract = !addOrSubtract
                }
                if addOrSubtract {
                    adjustedRotation -= fullCircle
                    tries.append("Rotation After Adding:      \(adjustedRotation) d:\(difference)")
                } else {
                    adjustedRotation += fullCircle
                    tries.append("Rotation After Subtracting: \(adjustedRotation) d:\(difference)")
                }
                previousDifference = difference
                difference = abs(ws.currentRotation - adjustedRotation)
                
                // The algorithm has gone all pearshaped.
                // This is a safty to break out of the loop
                // and continue on with the previously saved state
                if tries.count > tooManyTries {
                    adjustedRotation = ws.currentRotation
                    NSLog("Error: WheelControl could not calculate total rotation when passing over the discontinuity. Tried \(tries.count) times.")
                    for try in tries {
                        NSLog(try)
                    }
                    break
                }
            }
            
            let newDirection: DirectionRotated
            if adjustedRotation > ws.currentRotation {
                newDirection = .Clockwise
            } else if adjustedRotation < ws.currentRotation {
                newDirection = .CounterClockwise
            } else {
                // See above Error logging
                newDirection = ws.previousDirection
            }
            
            wheelState = WheelState( currentRotation: adjustedRotation,
                                    previousRotation: ws.currentRotation,
                                   previousDirection: newDirection)
            
        }
    }
    
    private let userState   = ImageWheelInteractionState()

    
    
    
    
    func addConstraintsToViews() {
        container.userInteractionEnabled = false
        self.addSubview(container)

        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        container.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        
        // constraints
        let viewsDictionary = ["controlView":container]
        
        //position constraints
        let view_constraint_H:[AnyObject] =
        NSLayoutConstraint.constraintsWithVisualFormat( "H:|[controlView]|",
                                               options: NSLayoutFormatOptions(0),
                                               metrics: nil,
                                                 views: viewsDictionary)
        
        let view_constraint_V:[AnyObject] =
        NSLayoutConstraint.constraintsWithVisualFormat( "V:|[controlView]|",
                                               options: NSLayoutFormatOptions(0),
                                               metrics: nil,
                                                 views: viewsDictionary)
        
        self.addConstraints(view_constraint_H)
        self.addConstraints(view_constraint_V)
        
        let wheelImageView     = UIImageView(image: UIImage(named: "WheelImage"))
        let wheelImageTypeView = UIImageView(image: UIImage(named: "WheelImageType"))
        
        wheelImageView.opaque = false
        wheelImageTypeView.opaque = false
        
        container.addSubview(wheelImageView)
        container.addSubview(wheelImageTypeView)
        
        
        wheelImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        wheelImageTypeView.setTranslatesAutoresizingMaskIntoConstraints(false)

        container.addConstraint(NSLayoutConstraint(item: wheelImageView,
            attribute: NSLayoutAttribute.CenterY,
            relatedBy: NSLayoutRelation.Equal,
            toItem: container,
            attribute: NSLayoutAttribute.CenterY,
            multiplier: 1.0,
            constant: 0.0))
        
        container.addConstraint(NSLayoutConstraint(item: wheelImageView,
            attribute: NSLayoutAttribute.CenterX,
            relatedBy: NSLayoutRelation.Equal,
            toItem: container,
            attribute: NSLayoutAttribute.CenterX,
            multiplier: 1.0,
            constant: 0.0))
        
        wheelImageView.addConstraint( NSLayoutConstraint(item: wheelImageView,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1.0,
            constant: 600.0))
        
        wheelImageView.addConstraint( NSLayoutConstraint(item: wheelImageView,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1.0,
            constant: 600.0))

        container.addConstraint(NSLayoutConstraint(item: wheelImageTypeView,
            attribute: NSLayoutAttribute.CenterY,
            relatedBy: NSLayoutRelation.Equal,
            toItem: container,
            attribute: NSLayoutAttribute.CenterY,
            multiplier: 1.0,
            constant: 0.0))
        
        container.addConstraint(NSLayoutConstraint(item: wheelImageTypeView,
            attribute: NSLayoutAttribute.CenterX,
            relatedBy: NSLayoutRelation.Equal,
            toItem: container,
            attribute: NSLayoutAttribute.CenterX,
            multiplier: 1.0,
            constant: 0.0))
        
        wheelImageTypeView.addConstraint( NSLayoutConstraint(item: wheelImageTypeView,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1.0,
            constant: 400.0))
        
        wheelImageTypeView.addConstraint( NSLayoutConstraint(item: wheelImageTypeView,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1.0,
            constant: 400.0))

        println("F:        T:        A:\(pad(currentAngle)) R:\(pad(currentRotation))")
    }
    
    
    func reset() {
        container.transform = CGAffineTransformMakeRotation(0.0)
        wheelState = WheelState(angle: currentAngle)
    }
    
    // MARK: -
    // MARK: UIControl methods handling the touches
    override func beginTrackingWithTouch(touch: UITouch,
        withEvent event: UIEvent) -> Bool {
        userState.reset()
        
        // Set state at the beginning of the users rotation
        userState.currently          = .Interacting
        userState.initialTransform   = container.transform
        userState.initialRotation    = currentRotation
        userState.initialTouchAngle  = angleAtTouch(touch)
        
        return true
    }
    
    override func continueTrackingWithTouch(touch: UITouch,
        withEvent event: UIEvent) -> Bool {

        let angleDifference = angleDifferenceBetweenTouch(touch,
                            AndAngle: userState.initialTouchAngle)
        
        container.transform = CGAffineTransformRotate( userState.initialTransform,
            angleDifference )
        currentRotation = userState.initialRotation + angleDifference
        
        self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
        self.sendActionsForControlEvents(UIControlEvents.TouchDragInside)
    
        return true
    }
    
    override func endTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) {
        
        // User interaction has ended, but most of the state is
        // still used through out this method.
        userState.currently = .NotInteracting
        
        // User rotation has ended.  Forget the state.
        userState.reset()

    }
    
    // MARK: -
    // MARK: Development Helpers
    // TODO: Remove after main development
    private lazy var padNumber: NSNumberFormatter = {
        let numberFormater = NSNumberFormatter()
        numberFormater.minimumIntegerDigits  = 2
        numberFormater.maximumIntegerDigits  = 2
        numberFormater.minimumFractionDigits = 3
        numberFormater.maximumFractionDigits = 3
        numberFormater.positivePrefix = " "
        return numberFormater
        }()
    
    private func pad(number: CGFloat) -> String {
        var paddedNumber = " 1.000"
        if let numberString = padNumber.stringFromNumber(number) {
            paddedNumber = numberString
        }
        return paddedNumber
    }

    // MARK: UITouch Helpers
    private func touchPointWithTouch(touch: UITouch) -> CGPoint {
        return touch.locationInView(self)
    }
    
    private func angleAtTouch(touch: UITouch) -> CGFloat {
        let touchPoint = touchPointWithTouch(touch)
        return angleAtTouchPoint(touchPoint)
    }
    
    
    private func angleAtTouchPoint(touchPoint: CGPoint) -> CGFloat {
        let dx = touchPoint.x - container.center.x
        let dy = touchPoint.y - container.center.y
        var angle = atan2(dy,dx)
        
        // Somewhere in the rotation of the container will be a discontinuity
        // where the angle flips from -3.14 to 3.14 or  back.  This adgustment
        // places that point in negitive Y.
        if angle >= quarterCircle {
            angle = angle - fullCircle
        }
        return angle
    }
    
    private func angleDifferenceBetweenTouch(touch: UITouch,
                                    AndAngle angle: CGFloat) -> CGFloat {
        let touchAngle = angleAtTouch(touch)
        var angleDifference = angle - touchAngle
                                        
        // Notice the angleDifference is flipped to negitive
        return -angleDifference
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

    // MARK: Angle Helpers
    private func normalizAngle(var angle: CGFloat) -> CGFloat {
        let positiveHalfCircle =  halfCircle
        let negitiveHalfCircle = -halfCircle
        
        while angle > positiveHalfCircle || angle < negitiveHalfCircle {
            if angle > positiveHalfCircle {
                angle -= fullCircle
            }
            if angle < negitiveHalfCircle {
                angle += fullCircle
            }
        }
        return angle
    }

    private func angleFromTransform(transform: CGAffineTransform) -> CGFloat {
        let b = transform.b
        let a = transform.a
        let radians = atan2(b, a)
        
        return radians
    }


}