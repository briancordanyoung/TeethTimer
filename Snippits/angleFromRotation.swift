// Playground - noun: a place where people can play

import UIKit

let halfCircle = CGFloat(M_PI)
let fullCircle = halfCircle * CGFloat(2)

func angleFromRotation(rotation: CGFloat) -> CGFloat {
    // outside the range of -32.5 to 32.5 this is faster
    var angle = rotation
    
    if angle >  halfCircle {
        angle += halfCircle
        let totalRotations = floor(angle / fullCircle)
        angle  = angle - (fullCircle * totalRotations)
        angle -= halfCircle
    }
    
    if angle < -halfCircle {
        angle -= halfCircle
        let totalRotations = floor(abs(angle) / fullCircle)
        angle  = angle + (fullCircle * totalRotations)
        angle += halfCircle
    }
    
    return angle
}

func angleFromRotationB(rotation: CGFloat) -> CGFloat {
    // within the range of -32.5 to 32.5 this is faster
    var angle = rotation
    
    while angle >  halfCircle || angle < -halfCircle {
        if angle >  halfCircle { angle -= fullCircle }
        if angle < -halfCircle { angle += fullCircle }
    }
    
    return angle
}

var test: CGFloat = halfCircle + 0.01
test = -32.5
let test1Start = NSDate()
angleFromRotation(test)
let test1End = NSDate()
let test2Start = NSDate()
angleFromRotationB(test)
let test2End = NSDate()

let test1Duration = test1End.timeIntervalSinceDate(test1Start)
let test2Duration = test2End.timeIntervalSinceDate(test2Start)