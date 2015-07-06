
import UIKit
import XCTest

class ImageWheelTests: XCTestCase {
  
    override func setUp() {
      super.setUp()
    }
  
    override func tearDown() {
        super.tearDown()
    }
    
    func testRotationIndexProgression() {
      let imageSeperation = Angle(degrees: 90)
      let imageCount      = Int(10)
      let maxIndex        = imageCount - 1
      let imageNames = arrayOfNames(imageCount)
      let imageWheel = InfiniteImageWheel(imageNames: imageNames,
        seperatedByAngle: imageSeperation,
        inDirection: .Clockwise)
      
      let testCount        = imageCount * 6
      var previousIndex    = 1
      let startingRotation = Rotation(imageSeperation) * (imageCount * 3 * -1)
      
      for i in 0..<testCount {
        let additionalRotation   = Rotation(imageSeperation) * i
        let currentRotation      = startingRotation + additionalRotation + Rotation(degrees: -1)
        imageWheel.rotation      = currentRotation
        let currentIndex         = imageWheel.rotationState.wedgeIndex

        var nextIndex = previousIndex - 1
        if nextIndex < 0 {
          nextIndex = maxIndex
        }

//        XCTAssert(false, "\(currentRotation.cgDegrees) - c: \(currentIndex) p: \(previousIndex)")
        XCTAssert(nextIndex == currentIndex, "Current Index is not next in the progression: Rot: \(currentRotation.cgDegrees) Is: \(currentIndex) Expected: \(nextIndex)")
          previousIndex = imageWheel.rotationState.wedgeIndex
        
        
      }
    }
    
  
  
  
  
  
  
  // Utility:
  func arrayOfNames(count: Int) -> [String] {
    var imageNames: [String] = []
    for i in 0..<count {
      imageNames.append(imageNameForNumber(i))
    }
    return imageNames
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
  

  
  
  
  
  
}
