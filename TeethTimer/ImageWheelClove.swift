//
//  ImageWheelClove.swift
//  TeethTimer
//
//  Created by Brian Cordan Young on 11/28/14.
//  Copyright (c) 2014 Brian Young. All rights reserved.
//

import Foundation

class ImageWheelClove: NSObject {
    var minValue: Float
    var maxValue: Float
    var midValue: Float
    var value: Int
    
    init(WithMin min: Float, AndMax max: Float, AndMid mid: Float, AndValue valueIn: Int) {
        minValue = min
        maxValue = max
        midValue = mid
        value = valueIn
        super.init()
    }
    
    func description() -> String {
        return "\(value) | \(minValue), \(midValue), \(maxValue)"
    }
}