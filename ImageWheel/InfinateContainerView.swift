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
                                       inDirection: .Clockwise)

    self.addSubview(imageWheel)
    self.imageWheel = imageWheel
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
  
  func arrayOfImages(count: Int) -> [UIImage] {
    var imageArray: [UIImage] = []
    for i in 1...count {
      if let image = UIImage(named: imageNameForNumber(i)) {
        imageArray.append(image)
      }
    }
    return imageArray
  }
  
  func arrayOfNames(count: Int) -> [String] {
    var imageNames: [String] = []
    for i in 1...(count - 0) {
      imageNames.append(imageNameForNumber(i))
    }
    return imageNames
  }

  
  func imageNameForNumber(i: Int) -> String {
    return "Gavin Poses-s\(paddedTwoDigitNumber(i))"
//    return "num-\(paddedTwoDigitNumber(i))"
  }
  
  
}