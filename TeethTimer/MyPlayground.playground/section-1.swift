import UIKit

typealias ImageIndex = Int

//firstImageRotation 2.35619
//wedgeWidthAngle 1.5708
//images.count 10

//var firstImageRotation = CGFloat(2.35619)
//var wedgeWidthAngle    = CGFloat(1.5708)
//var images             = [1,2,3,4,5,6,7,8,9,10]
//
//func imageIndexForRotation(rotation: CGFloat) -> ImageIndex {
//  let startingRotationDifference = -firstImageRotation
//  let rotationStartingAtZero = rotation + startingRotationDifference
//  let wedgesFromStart = rotationStartingAtZero / wedgeWidthAngle
//  // assumes: images increase as rotation decreases
//  var currentImage = ImageIndex(round(-wedgesFromStart)) + 1
//  
//  while currentImage > images.count || currentImage < 1 {
//    if currentImage < 1 {
//      currentImage += images.count
//    }
//    if currentImage > images.count {
//      currentImage -= images.count
//    }
//  }
//  return currentImage
//}
//
//let checkRot = CGFloat(01.581)
//let startRot = checkRot - (wedgeWidthAngle * 2)
//var rots: [Int] = []
//
//for i in 1...4 {
//  let rot = (CGFloat(i) * wedgeWidthAngle) + startRot
//  rots.append(imageIndexForRotation(rot))
//}
//
//rots


for i in -3...4 {
  println(i)
}

