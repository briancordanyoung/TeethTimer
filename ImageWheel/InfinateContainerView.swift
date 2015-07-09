import UIKit




class InfinateContainerView: UIView {
  
  var imageWheel: InfiniteImageWheel?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupImageWheel()
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupImageWheel()
  }
  
  
  func setupImageWheel() {
    let imageNames = arrayOfNames(10)
    let imageWheel = InfiniteImageWheel(imageNames: imageNames,
                                  seperatedByAngle: Angle(degrees: 90),
                                       inDirection: .ClockwiseLayout)
    self.addSubview(imageWheel)
    self.imageWheel = imageWheel
    
    
//    let rot = imageWheel.rotationForIndex(0)
//    println("rot: \(rot.degrees)")

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
  
  func arrayOfNames(count: Int) -> [String] {
    var imageNames: [String] = []
    for i in 0...(count - 1) {
      imageNames.append(imageNameForNumber(i))
    }
    return imageNames
  }
  
  
  func imageNameForNumber(i: Int) -> String {
//    return "Gavin Poses-s\(paddedTwoDigitNumber(i))"
        return "num-\(paddedTwoDigitNumber(i))"
  }
  
  
}