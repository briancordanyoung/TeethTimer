
import UIKit
import XCTest

class RotationStateTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  // MARK: Tests
  func testRotationIndexProgression() {
    let imageSeperation = Angle(degrees: 90)
    let imageCount      = Int(10)
    let maxIndex        = imageCount - 1
    let imageNames      = arrayOfNames(imageCount)
    let wedges = imageNames.map({
      InfiniteImageWheel.Wedge(imageName: $0)
    })
    let series = InfiniteImageWheel.WedgeSeries(wedges: wedges,
                                             direction: .ClockwiseLayout,
                                       wedgeSeperation: imageSeperation,
                                          visibleAngle: imageSeperation)
    
    
    let testCount        = imageCount * 6
    var previousIndex    = 1
    let startingRotation = Rotation(imageSeperation) * (imageCount * 3 * -1)
    
    for i in 0..<testCount {
      let additionalRotation   = Rotation(imageSeperation) * i
      let randomOffset = randomRotationWithinRotation(imageSeperation.rotation)
      let currentRotation = startingRotation + additionalRotation + randomOffset
      let state     = InfiniteImageWheel.RotationState(rotation: currentRotation,
                                                    wedgeSeries: series)
      let currentIndex         = state.wedgeIndex
      
      var nextIndex = previousIndex - 1
      if nextIndex < 0 {
        nextIndex = maxIndex
      }
      
      var msg = "Current Index is not next in the progression: "
      msg += "Rot: \(currentRotation.degrees) "
      msg += "Is: \(currentIndex) "
      msg += "Expected: \(nextIndex)"
      XCTAssert(nextIndex == currentIndex, msg)
      
      previousIndex = state.wedgeIndex
    }
  }
  
  
  func testRotationCounterIndexProgression() {
    let imageSeperation = Angle(degrees: 90)
    let imageCount      = Int(10)
    let maxIndex        = imageCount - 1
    let imageNames      = arrayOfNames(imageCount)
    let wedges = imageNames.map({
      InfiniteImageWheel.Wedge(imageName: $0)
    })
    let series = InfiniteImageWheel.WedgeSeries(wedges: wedges,
                                             direction: .CounterClockwiseLayout,
                                       wedgeSeperation: imageSeperation,
                                          visibleAngle: imageSeperation)
    
    let testCount        = imageCount * 6
    var previousIndex    = 1
    let startingRotation = Rotation(imageSeperation) * (imageCount * 3 * -1)
    
    for i in 0..<testCount {
      let additionalRotation   = Rotation(imageSeperation) * i
      let randomOffset = randomRotationWithinRotation(imageSeperation.rotation)
      let currentRotation = startingRotation + additionalRotation + randomOffset
      let state     = InfiniteImageWheel.RotationState(rotation: currentRotation,
                                                    wedgeSeries: series)
      let currentIndex = state.wedgeIndex
      
      var nextIndex = previousIndex - 1
      if nextIndex < 0 {
        nextIndex = maxIndex
      }
      
      var msg = "Current Index is not next in the progression: "
      msg += "Rot: \(currentRotation.degrees) "
      msg += "Is: \(currentIndex) "
      msg += "Expected: \(nextIndex)"
      XCTAssert(nextIndex == currentIndex, msg)
      
      previousIndex = state.wedgeIndex
    }
  }
 
  
  func testWedgeRotationProgression() {
  
    let imageSeperation = Angle(degrees: 90)
    let imageCount      = Int(10)
    let maxIndex        = imageCount - 1
    let imageNames      = arrayOfNames(imageCount)
    let wedges = imageNames.map({
      InfiniteImageWheel.Wedge(imageName: $0)
    })
    let series = InfiniteImageWheel.WedgeSeries(wedges: wedges,
                                             direction: .ClockwiseLayout,
                                       wedgeSeperation: imageSeperation,
                                          visibleAngle: imageSeperation)
    
    
    
    let testCount           = imageCount * 6
    let startingRotation    = Rotation(imageSeperation) * (imageCount * 3 * -1)
    
    for i in 0..<testCount {
      let randomOffset = randomRotationWithinRotation(imageSeperation.rotation)
      
      let additionalRotation   = Rotation(imageSeperation) * i
      let currentRotation      = startingRotation + additionalRotation
      let randomizedRotation   = currentRotation + randomOffset
      
      let state     = InfiniteImageWheel.RotationState(rotation: randomizedRotation,
                                                    wedgeSeries: series)
      
      var msg = "Current Wedge Center is not next in the progression: "
      msg += "Rot: \(randomizedRotation.degrees) "
      msg += "count: \(i) "
      msg += "Is: \(state.wedgeCenter.degrees  ) "
      msg += "Expected: \(currentRotation.degrees)"
      XCTAssert(rotationsAreClose(state.wedgeCenter, currentRotation), msg)
    }
  }
  
  
  func testCounterWedgeRotationProgression() {
  
    let imageSeperation = Angle(degrees: 90)
    let imageCount      = Int(10)
    let maxIndex        = imageCount - 1
    let imageNames      = arrayOfNames(imageCount)
    let wedges = imageNames.map({
      InfiniteImageWheel.Wedge(imageName: $0)
    })
    let series = InfiniteImageWheel.WedgeSeries(wedges: wedges,
                                             direction: .CounterClockwiseLayout,
                                       wedgeSeperation: imageSeperation,
                                          visibleAngle: imageSeperation)
    
    
    
    let testCount           = imageCount * 6
    let startingRotation    = Rotation(imageSeperation) * (imageCount * 3 * -1)
    
    for i in 0..<testCount {
      let randomOffset = randomRotationWithinRotation(imageSeperation.rotation)
      
      let additionalRotation   = Rotation(imageSeperation) * i
      let currentRotation      = startingRotation + additionalRotation
      let randomizedRotation   = currentRotation + randomOffset
      
      let state     = InfiniteImageWheel.RotationState(rotation: randomizedRotation,
                                                    wedgeSeries: series)
      
      var msg = "Current Wedge Center is not next in the progression: "
      msg += "Rot: \(randomizedRotation.degrees) "
      msg += "count: \(i) "
      msg += "Is: \(state.wedgeCenter.degrees  ) "
      msg += "Expected: \(currentRotation.degrees)"
      XCTAssert(rotationsAreClose(state.wedgeCenter, currentRotation), msg)
    }
  }
  
  
  
  
  // MARK: Utility
  func rotationsAreClose(a: Rotation,_ b: Rotation) -> Bool {
    let precision = Double(10000)
    var rotA = Int64(a.value * precision)
    var rotB = Int64(b.value * precision)
    return rotA == rotB
  }
  
  // Return a Rotation that is randomly between -(rotation/2) & (rotation/2)
  func randomRotationWithinRotation(rotation: Rotation) -> Rotation {
    // arc4random works with integers. Before turning degrees (a double) in to 
    // an Int (UInt32), first multiply it by 'precision'
    let precision       = UInt32(100)
    
    let randomRange     = UInt32(rotation.degrees * 0.999 * Double(precision))
    let halfRange       = rotation.degrees * 0.4995
    
    // Divide by 'precision' to return to the same order of magnitude that the
    // original degrees were in.
    let randomOffset    = Double(arc4random_uniform(randomRange)) /
                          Double(precision)
    let randomOffsetDegrees = randomOffset - halfRange
    
    return Rotation(degrees: randomOffsetDegrees)
  }

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
  
  
  
  
  
  
  
  
}
