//
//  ImageWheelInteractionState.swift
//  TeethTimer
//
//  Created by Brian Cordan Young on 2/8/15.
//  Copyright (c) 2015 Brian Young. All rights reserved.
//

import UIKit

class ImageWheelInteractionState {
    
    var isInteracting = false
    var isNotInteracting: Bool {
        get {
            return !isInteracting
        }
        set(notInteracting) {
            isInteracting = !notInteracting
        }
    }
    
    var wedgeOpacityList = Dictionary<Int, CGFloat>()
    var startTransform = CGAffineTransformMakeRotation(0)
    var wedgeValueBeforeTouch = 1     // wedge to image?
    var returnToPreviousWedge = false // wedge to image?
    var dontReturnToPreviousWedge: Bool {
        get {
            return !returnToPreviousWedge
        }
        set(dontReturnToPreviousWedge) {
            returnToPreviousWedge = !dontReturnToPreviousWedge
        }
    }
    
    
    var previousAngle: CGFloat   = 0.0
    var firstTouchAngle: CGFloat = 0.0
    
    var wheelHasFlipped360: Bool = false
    
    var userRotatedPositive: Bool?
    var userRotatedNegitive: Bool? {
        get {
            if let userRotatedPositive_ = userRotatedPositive {
                return !userRotatedPositive_
            } else {
                return nil
            }
        }
        set(rotatedNegitive) {
            if let rotatedNegitive_ = rotatedNegitive {
                userRotatedPositive = !rotatedNegitive_
            } else {
                userRotatedPositive = nil
            }
        }
    }
    
    
    init() {
        reset()
    }
    
    func reset() {
        isNotInteracting = true
        dontReturnToPreviousWedge = true
        previousAngle   = 0.0
        firstTouchAngle = 0.0
        wheelHasFlipped360 = false
        userRotatedPositive = nil
        startTransform = CGAffineTransformMakeRotation(0)
        clearWedgeOpacityList()
    }
    
    func clearWedgeOpacityList() {
        wedgeOpacityList = Dictionary<Int, CGFloat>()
    }
    
    func initOpacityListWithWedges( wedges: [WedgeRegion]) {
        for wedge in wedges {
            wedgeOpacityList[wedge.value] = CGFloat(0)
        }
    }
    
    func setOpacityOfWedgeImageViews(views: [UIImageView]) {
        assert(wedgeOpacityList.count == views.count, "setOpacityOfWedgeImageViews requires both the wedgeOpacityList and views arrays to each have the same number of elements.")
        for view in views {
            if let opacityValue = wedgeOpacityList[view.tag] {
                view.alpha = opacityValue
            }
        }
    }
}

