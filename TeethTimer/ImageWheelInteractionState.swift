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
    
    
    var previousAngle: CGFloat?
    
    var wheelHasFlipped360Changed: (String) -> Void = {text in}
    var wheelHasFlipped360: Bool = false {
        didSet(previousStatus)
        {
            if wheelHasFlipped360 {
                println("Flipped")
                //                wheelHasFlipped360Changed("Flipped")
                //                var timer = NSTimer.scheduledTimerWithTimeInterval( 1.0,
                //                    target: self,
                //                    selector:  Selector("clearWheelHasFlipped360Changed"),
                //                    userInfo: nil,
                //                    repeats: false)
            }
        }
    }
    
    var userRotatedChanged:  (String) -> Void = {text in}
    var userRotatedPositive: Bool? {
        didSet(previousStatus)
        {
            var text = ""
            
            if let userRotatedPositive_ = userRotatedPositive {
                if userRotatedPositive_ {
                    text = "Pos"
                } else {
                    text = "Neg"
                }
            }
            userRotatedChanged(text)
        }
    }
    
    var userRotatedNegitive: Bool? {
        get {
            if let pos = userRotatedPositive {
                return !pos
            } else {
                return nil
            }
        }
        set(rotatedNegitive) {
            if let neg = rotatedNegitive {
                userRotatedPositive = !neg
            } else {
                userRotatedPositive = nil
            }
        }
    }
    
    
    init() {
        resetState()
    }
    
    func resetState() {
        isNotInteracting = true
        dontReturnToPreviousWedge = true
        previousAngle = nil
        wheelHasFlipped360 = false
        userRotatedPositive = nil
        startTransform = CGAffineTransformMakeRotation(0)
        clearWedgeOpacityList()
    }
    
    func clearWedgeOpacityList() {
        wedgeOpacityList = Dictionary<Int, CGFloat>()
    }
    
    func initOpacityListWithWedges( wedges: [WedgeRegion],
        AndViews   views: [UIImageView] ) {
            
            clearWedgeOpacityList()
            assert(wedges.count == views.count, "setOpacityListWithWedges requires both the wedges and views arrays to each have the same number of elements.")
            for (i,wedge) in enumerate(wedges) {
                let view = views[i]
                wedgeOpacityList[wedge.value] = view.alpha
            }
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
    
    func clearWheelHasFlipped360Changed() {
        wheelHasFlipped360Changed("")
    }
}

