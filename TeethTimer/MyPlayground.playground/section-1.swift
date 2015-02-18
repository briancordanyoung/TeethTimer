// Playground - noun: a place where people can play

import UIKit

func normalizedAngleForAngle(var angle: Float) -> Float {
    let positiveHalfCircle = Float(M_PI)
    let negitiveHalfCircle = Float(M_PI * -1)
    let fullCircle = Float(M_PI * 2)
    
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


normalizedAngleForAngle(0)
normalizedAngleForAngle(-234.23)