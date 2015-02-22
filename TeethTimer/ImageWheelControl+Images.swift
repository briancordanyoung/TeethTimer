//
//  ImageWheelControl+Images.swift
//  TeethTimer
//
//  Created by Brian Cordan Young on 2/20/15.
//  Copyright (c) 2015 Brian Young. All rights reserved.
//

import UIKit

extension ImageWheelControl {
    
    
    func wedgeForImage(image: ImageIndex) -> WedgeRegion {
        let wedgeValue = image % wedges.count
        return wedgeFromValue(wedgeValue)
    }
    
    // MARK: -
    // MARK: Rotation Methods (Without Animating)
    func rotateToImage(image: ImageIndex) {
        visualState.imageWheelFullRotations = image / wedges.count
        let wedge = wedgeForImage(image)
        rotateToWedge(wedge)
    }
    
    // MARK: Animation Methods
    func animateToImage(image: ImageIndex) {
        animateToImage(image, inDirection: .Closest)
    }
    
    
    func animateToImage(image: ImageIndex,
        inDirection direction: DirectionToRotate) {
            
            var currentWedge = self.currentWedge
            var steps: [ImageWheelRotationKey] = []
            let resolved = resolveDirectionAndCountToImage( image,
                                               inDirection: direction)
            
            if resolved.count == 0 {
                let aStep = ImageWheelRotationKey(timePercent: 1.0,
                                                        wedge: currentWedge)
                steps.append(aStep)
                
            } else {
                let timeSlice = 1.0 / CGFloat(resolved.count)
                for i in 1...resolved.count {
                    if resolved.direction == .Clockwise {
                        currentWedge = nextWedge(currentWedge)
                    } else {
                        currentWedge = previousWedge(currentWedge)
                    }
                    
                    
                    let aStep = ImageWheelRotationKey(timePercent: timeSlice,
                                                            wedge: currentWedge)
                    steps.append(aStep)
                }
            }
            
            animateToEachStep(steps)
    }

    func resolveDirectionAndCountToImage(image: ImageIndex,
                     var inDirection direction: DirectionToRotate)
                                 -> (direction: DirectionToRotate, count: Int) {
            
            let count: Int
            
            switch direction {
            case .Closest:
                let positiveCount = countFromImage( currentImage,
                                           ToImage: image,
                                       inDirection: .Clockwise)
                let negitiveCount = countFromImage( currentImage,
                                           ToImage: image,
                                       inDirection: .CounterClockwise)
                
                if positiveCount <= negitiveCount {
                    count     = positiveCount
                    direction = .Clockwise
                } else {
                    count     = negitiveCount
                    direction = .CounterClockwise
                }
                
            case .Clockwise:
                count = countFromImage( currentImage,
                               ToImage: image,
                           inDirection: .Clockwise)
                
            case .CounterClockwise:
                count = countFromImage( currentImage,
                               ToImage: image,
                           inDirection: .CounterClockwise)

            }
            
            return (direction, count)
            
    }
    
    func countFromImage( fromImage: ImageIndex,
                 ToImage toImage: ImageIndex,
             inDirection direction: DirectionRotated) -> Int {
            
            var image = fromImage
            var count = 0
            while true {
                if image == toImage {
                    break
                }
                if direction == .Clockwise {
                    image = nextImage(image)
                } else {
                    image = previousImage(image)
                }
                ++count
            }
            return count
    }
    
    func nextImage(var image: ImageIndex) -> ImageIndex {
        ++image
        if image > images.count {
            image = 1
        }
        return image
    }
    
    func previousImage(var image: ImageIndex) -> ImageIndex {
        --image
        if image < 1 {
            image = images.count
        }
        return image
    }


}