import Foundation

// A number that represents the degrees or radians around a circle.
final class Revolution: NumericType {
  
  var value: Double
  var angle: Angle       { return   Angle(value) }
//var cgAngle: CGFloat   { return CGFloat(value) }

  init(_ value: Angle) {
    self.value = value.radians
  }
  
  init(_ value: CGFloat) {
    self.value = Double(value)
  }
  
  init(_ value: Double) {
    self.value = value
  }
  

  convenience init(radians: Angle) {
    self.init(radians)
  }
  
  convenience init(radians: CGFloat) {
    self.init(Double(radians))
  }
  
  convenience init(radians: Double) {
    self.init(radians)
  }
  
  convenience init(preset: Preset) {
    let radians = Revolution.preset(preset)
    self.init(radians: radians)
  }
}

extension Revolution {
  enum Preset {
    case full
    case half
    case quarter
    case threeQuarter
    case tau
    case pi
  }
}

// MARK: Class Methods
extension Revolution {
  class func preset(preset: Preset) -> Angle {
    switch preset {
    case .full,
         .tau:
      return Angle(M_PI * 2)
    case .half,
         .pi:
      return Angle(M_PI)
    case .quarter:
      return Angle(M_PI * 0.50)
    case .threeQuarter:
      return Angle(M_PI * 1.50)
    }
  }
  
  class var full: Angle {
    return Revolution.preset(.full)
  }
  
  class var half: Angle {
    return Revolution.preset(.half)
  }
  
  class var quarter: Angle {
    return Revolution.preset(.quarter)
  }
  
  class var threeQuarter: Angle {
    return Revolution.preset(.threeQuarter)
  }
}

// MARK: Protocol Conformance
extension Revolution: IntegerLiteralConvertible {
  convenience init(integerLiteral: IntegerLiteralType) {
    self.init(integerLiteral: integerLiteral)
  }
}

extension Revolution: FloatLiteralConvertible {
  convenience init(floatLiteral: FloatLiteralType) {
    self.init(floatLiteral)
  }
}

