
import UIKit
import XCTest

class wedgeStateTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  // MARK: Tests
//  func testRotationIndexProgression() {
//  }
  
  
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
