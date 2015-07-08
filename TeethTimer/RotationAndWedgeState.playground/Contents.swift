import UIKit

// Utility:
func paddedTwoDigitNumber(i: Int) -> String {
  var paddedTwoDigitNumber = "00"
  
  let numberFormater = NSNumberFormatter()
  numberFormater.minimumIntegerDigits  = 2
  numberFormater.maximumIntegerDigits  = 2
  numberFormater.minimumFractionDigits = 0
  numberFormater.maximumFractionDigits = 0
  
  if let numberString = numberFormater.stringFromNumber(i) {
    paddedTwoDigitNumber = numberString
  }
  return paddedTwoDigitNumber
}

func imageNameForNumber(i: Int) -> String {
  return "num-\(paddedTwoDigitNumber(i))"
}


func arrayOfNames(count: Int) -> [String] {
  var imageNames: [String] = []
  for i in 0..<count {
    imageNames.append(imageNameForNumber(i))
  }
  return imageNames
}







func rotationsAreClose(a: Rotation, b: Rotation) -> Bool {
  var rotA = Int64(a.value * 10000)
  var rotB = Int64(b.value * 10000)
  return rotA == rotB
}


// Return a Rotation that is randomly between -(rotation/2) & (rotation/2)
func randomRotationWithinRotation(rotation: Rotation) -> Rotation {
  // arc4random works with integers. Before turning degrees (a double) in to
  // an Int (UInt32), first multiply it by 'precision'
  let precision       = UInt32(1)
  
  let degrees         = rotation.degrees
  let randomRange     = UInt32(degrees * 0.999 * Double(precision))
  let halfRange       = degrees * 0.4995
  
  // Divide by 'precision' to return to the same order of magnitude that the
  // original degrees were in.
  let randomOffset    = Double(arc4random_uniform(randomRange)) /
    Double(precision)
  
  // subtract half the range to center the random number around 0
  let randomOffsetDegrees = randomOffset - halfRange
  
  return Rotation(degrees: randomOffsetDegrees)
}





//////////////////////////////////////////////////////


let imageNames = arrayOfNames(10)
let wedges = imageNames.map({
  Wedge(imageName: $0)
})


let series = WedgeSeries(wedges: wedges,
                      direction: .Clockwise,
                wedgeSeperation: Angle(degrees: 90),
                   visibleAngle: Angle(degrees: 90))

//////////////////////////////////////////////////////
//for i in -72...72 {
//  
//  let rotation = Rotation(degrees: (i * 10))
//  rotation.degrees
//  let rotState = RotationState(rotation: rotation,
//                            wedgeSeries: series)
//  
//  rotState.wedgeCenter.degrees
//  let string = "\(rotation.degrees) \(rotState.wedgeCenter.degrees)"
//}


//////////////////////////////////////////////////////

let imageSeperation = Angle(degrees: 90)
let imageCount      = Int(10)
let maxIndex        = imageCount - 1

let testCount           = imageCount * 6
let startingRotation    = Rotation(imageSeperation) * Rotation(imageCount * 3 * -1)
var previousWedgeCenter = startingRotation - Rotation(imageSeperation)

for i in 0..<testCount {
  
  let additionalRotation   = Rotation(imageSeperation) * Rotation(i)
  let currentRotation      = startingRotation + additionalRotation
  
  let randomOffset         = randomRotationWithinRotation(imageSeperation.rotation)
  let randomizedRotation   = currentRotation + randomOffset
  
  
  let state = RotationState(    rotation: randomizedRotation,
                             wedgeSeries: series)
  
  let test = rotationsAreClose(state.wedgeCenter, currentRotation)
  let string = "\(randomizedRotation.degrees) \(state.wedgeCenter.degrees) \(currentRotation.degrees)"
 
}

  let state = RotationState(    rotation: Rotation(degrees: 34.135),
                             wedgeSeries: series)
  state.wedgeCenter



