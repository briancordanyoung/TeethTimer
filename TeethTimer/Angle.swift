import Foundation


// MARK: Angle - A number that represents an angle in both degrees or radians.
struct Angle: NumericType {
  
  var value: Double
  
  init(_ value: Double) {
    self.value = value
  }
  
  init(_ value: CGFloat) {
    self.value = Double(value)
  }
  
  init(_ value: Int) {
    self.value = Double(value)
  }

  
  init(radians: Double) {
    self.init(radians)
  }
  
  init(radians: CGFloat) {
    self.init(Double(radians))
  }
  
  init(radians: Int) {
    self.init(Double(radians))
  }
  
  
  init(degrees: Double) {
    self.init(radians: degrees * Double(M_PI) / 180.0)
  }
  
  init(degrees: CGFloat) {
    self.init(degrees: Double(degrees))
  }
  
  init(degrees: Int) {
    self.init(degrees: Double(degrees))
  }
  
  
  var radians: Double  {
    return value
  }
  
  var degrees: Double {
    return radian2Degree(value)
  }
  
  var cgRadians: CGFloat  {
    return CGFloat(value)
  }
  
  var cgDegrees: CGFloat {
    return CGFloat(radian2Degree(value))
  }
  
  private func radian2Degree(radian:Double) -> Double {
    return radian * 180.0 / Double(M_PI)
  }
  
}

// MARK: Protocol Conformance
extension Angle: IntegerLiteralConvertible {
  init(integerLiteral: IntegerLiteralType) {
    self.init(Double(integerLiteral))
  }
}

extension Angle: FloatLiteralConvertible {
  init(floatLiteral: FloatLiteralType) {
    self.init(Double(floatLiteral))
  }
}


// MARK: Overload for common math function to act on Angle
func floor(x: Angle) -> Angle {
  return Angle(floor(x.value))
}

func log(x: Angle) -> Angle {
  return Angle(log(x.value))
}

func abs(x: Angle) -> Angle {
  return Angle(abs(x.value))
}

// MARK: Extend Int to initialize with an Angle instance
extension Int {
  init(_ value: Angle) {
    self = Int(value.value)
  }
}

