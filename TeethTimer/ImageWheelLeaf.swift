//
//  ImageWheelLeaf.swift
//  TeethTimer
//
//  Created by Brian Cordan Young on 11/28/14.
//  Copyright (c) 2014 Brian Young. All rights reserved.
//


struct ImageWheelLeaf {
    var minRadian: Float
    var maxRadian: Float
    var midRadian: Float
    var value: Int
    
    init(WithMin min: Float, AndMax max: Float, AndMid mid: Float, AndValue valueIn: Int) {
        minRadian = min
        maxRadian = max
        midRadian = mid
        value = valueIn
    }
    
    func description() -> String {
        return "\(value) | \(minRadian), \(midRadian), \(maxRadian)"
    }
}