import Foundation

enum RevolutionPreset {
  case full
  case half
  case quarter
  case threeQuarter
}


// A number that represents the degrees or radians around a circle.
final class Revolution: NumericType {
  
  var value: Double

  var revolution: Double {
    return value
  }

  class func preset(preset: RevolutionPreset) -> CGFloat {
    switch preset {
    case .full:
      return CGFloat(M_PI) * CGFloat(2.00)
    case .half:
      return CGFloat(M_PI)
    case .quarter:
      return CGFloat(M_PI) * CGFloat(0.50)
    case .threeQuarter:
      return CGFloat(M_PI) * CGFloat(1.50)
    }
  }
  
  class var full: CGFloat {
    return Revolution.preset(.full)
  }

  class var half: CGFloat {
    return Revolution.preset(.half)
  }
 
  class var quarter: CGFloat {
    return Revolution.preset(.quarter)
  }

  class var threeQuarter: CGFloat {
    return Revolution.preset(.threeQuarter)
  }


  init(_ value: Double) {
    self.value = value
  }
  
  init(_ value: CGFloat) {
    self.value = Double(value)
  }
  

  convenience init(radians: Double) {
    self.init(radians)
  }
  
  convenience init(radians: CGFloat) {
    self.init(Double(radians))
  }
  
  convenience init(preset: RevolutionPreset) {
    let radians = Double(Revolution.preset(preset))
    self.init(radians: radians)
  }
  
  convenience init(degrees: Double) {
    self.init(radians: degrees * Double(M_PI) / 180.0)
  }
  
  convenience init(degrees: CGFloat) {
    self.init(degrees: Double(degrees))
  }
  
  var radians: CGFloat  {
    return CGFloat(revolution)
  }
  
  var degrees: CGFloat {
    return CGFloat(radian2Degree(revolution))
  }


  private func radian2Degree(radian:Double) -> Double {
    return radian * 180.0 / Double(M_PI)
  }
  
  private func degreesToRadians (value:Double) -> Double {
    return value * Double(M_PI) / 180.0
  }
  
}


extension Revolution: IntegerLiteralConvertible {
  convenience init(integerLiteral: IntegerLiteralType) {
    self.init(Double(integerLiteral))
  }
}

extension Revolution: FloatLiteralConvertible {
  convenience init(floatLiteral: FloatLiteralType) {
    self.init(Double(floatLiteral))
  }
}

