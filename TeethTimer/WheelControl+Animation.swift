
import UIKit

extension WheelControl {

  // MARK: POP Animation Delegate Callback
  func pop_animationDidApply(anim: Animation!) {
    let angle = Angle(rotationState.previous)
    let angleDifference = currentAngle - angle
    self.setRotation(currentRotation + Rotation(angleDifference))
  }
  
  
  // MARK: -
  // MARK: Animation Methods
  
//    func animateToRotation(rotation: Angle) {
//        Animation.removeAllAnimations(wheelView.layer)
//        let currentRotation = self.currentRotation
//
//
//        let springAngularDistance = halfCircle / 3
//        let totalAngularDistance = abs(currentRotation - rotation)
//
//        if totalAngularDistance <= springAngularDistance {
//            springRotationAnimation( from: currentRotation,
//                                       to: rotation)
//        } else {
//            let durationPerRadian = CGFloat(0.25)
//            let baseDuration = totalAngularDistance * durationPerRadian
//            let totalDuration = speedUpDurationByDistance(baseDuration)
//
//            let part1Distance    = totalAngularDistance - springAngularDistance
//            let part1Percentage  = part1Distance / totalAngularDistance
//            let part1Duration    = totalDuration * part1Percentage
//            let part1Rotation    = ((rotation - currentRotation ) * part1Percentage) + currentRotation
//
//            basicRotationAnimation( from: currentRotation,
//                                      to: part1Rotation,
//                duration: part1Duration) { anim, finsihed in
//                    self.springRotationAnimation(from: part1Rotation,
//                                                   to: rotation)
//            }
//
//        }
//    }
  
  func animateToRotation(rotation: Rotation) { // in module, make public //
    rotationState.target = rotation
    
    
    func speedUpDurationByDistance(duration: CGFloat) -> CGFloat {
      let durationDistanceFactor = CGFloat(1)
      return log((duration * durationDistanceFactor) + 1) / durationDistanceFactor
    }
    
    Animation.removeAllAnimations(wheelView.layer)
    let durationPerRadian = CGFloat(0.25)
    let totalAngularDistance = abs(currentRotation - rotation)
    let baseDuration = totalAngularDistance.cgRadians * durationPerRadian
    let totalDuration = speedUpDurationByDistance(baseDuration)
    let timing = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    
    let rotate = BasicAnimation(duration: totalDuration, timingFunction: timing)
    rotate.property = AnimatableProperty(name: kPOPLayerRotation)
    rotate.fromValue = currentRotation.cgRadians
    rotate.toValue   = rotation.cgRadians
    rotate.name = "Basic Rotation"
    rotate.delegate = self
    rotate.completionBlock = { anim, finished in
      if finished {
        self.currentAngle         = Angle(rotation)
        self.currentRotation      = rotation
        self.rotationState.target = nil
      }
    }
    
    Animation.removeAllAnimations(wheelView.layer)
    Animation.addAnimation( rotate,
      key: rotate.property.name,
      obj: wheelView.layer)
  }
  
  
  func basicRotationAnimation(#from: Rotation,
    to: Rotation,
    duration: CGFloat,
    completion: (Animation, Bool)->()) {
      
      let rotate = BasicAnimation(duration: duration)
      rotate.property  = AnimatableProperty(name: kPOPLayerRotation)
      rotate.fromValue = from.cgRadians
      rotate.toValue   =   to.cgRadians
      rotate.name = "Basic Rotation"
      rotate.delegate = self
      Animation.removeAllAnimations(wheelView.layer)
      Animation.addAnimation( rotate,
        key: rotate.property.name,
        obj: wheelView.layer)
      
  }
  
  
  func springRotationAnimation(#from: Rotation, to: Rotation) {
    
    let spring = SpringAnimation( tension: 1000,
      friction: 30,
      mass: 1)
    spring.property  = AnimatableProperty(name: kPOPLayerRotation)
    spring.fromValue = from.cgRadians
    spring.toValue   =   to.cgRadians
    spring.name = "Spring Rotation"
    spring.delegate = self
    spring.completionBlock = { anim, finished in
      if finished {
        self.currentAngle = Angle(to)
        self.setRotation(to)
        self.rotationState.target = nil
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