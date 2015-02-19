// Playground - noun: a place where people can play

import UIKit

func normalizedAngleForAngle(var angle: CGFloat) -> CGFloat {
    let halfCircle = CGFloat(M_PI)
    let fullCircle = CGFloat(M_PI) * 2
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


normalizedAngleForAngle(0)
normalizedAngleForAngle(34.23)
