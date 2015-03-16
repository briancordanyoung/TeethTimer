// Playground - noun: a place where people can play

import UIKit
let halfCircle = CGFloat(M_PI)
let fullCircle = CGFloat(M_PI) * 2
let quarterCircle = CGFloat(M_PI) / 2
let threeQuarterCircle = quarterCircle + halfCircle
var rotationDampeningFactor  = CGFloat(5)


private func dampenClockwiseAngleDifference(var angle: CGFloat) -> CGFloat {
    angle = -angle
    
    let oldAngle = angle
    
    while angle <= 0 {
        angle += fullCircle
    }
    
    
    let newAngle = (log((angle * rotationDampeningFactor) + 1) / rotationDampeningFactor)
    
    //        println("o: \(pad(oldAngle))  n: \(pad(newAngle))")
    return -newAngle
}

var numbers: [CGFloat] = [-0.151, -0.165, -0.188, -0.196, -0.216, -0.226, -0.247, -0.260]

for n in numbers {
    dampenClockwiseAngleDifference(n)
}

var x = numbers[0]
while x > numbers.last {
    dampenClockwiseAngleDifference(x)
    x -= 0.01
}
