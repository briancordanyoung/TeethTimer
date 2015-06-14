import UIKit




class ContainerView: UIView {
  
  var imageWheel: ImageWheel?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupImageWheelAndAddToGavinWheel()
  }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupImageWheelAndAddToGavinWheel()
  }
  
  
  func setupImageWheelAndAddToGavinWheel() {
    let images = arrayOfImages(10)
    let imageWheel = ImageWheel(Sections: 4, AndImages: images)
    self.addSubview(imageWheel)
    
//     Set the inital rotation
//    let startingRotation = imageWheel.wedgeFromValue(1).midAngle
//    imageWheel.rotationAngle = CGFloat(startingRotation)
    
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
  
  func imageNameForNumber(i: Int) -> String {
    return "Gavin Poses-s\(paddedTwoDigitNumber(i))"
  }

  
}