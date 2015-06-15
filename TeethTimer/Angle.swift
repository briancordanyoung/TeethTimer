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
    self.init(radians: Angle.degrees2radians(degrees))
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
    return Angle.radians2Degrees(value)
  }
  
  static func radians2Degrees(radians:Double) -> Double {
    return radians * 180.0 / Double(M_PI)
  }
  
  static func degrees2radians(degrees:Double) -> Double {
    return degrees * Double(M_PI) / 180.0
  }
}


// Convenience Computed Properties to convert to CGFloat
extension Angle {
  var cgRadians: CGFloat  {
    return CGFloat(radians)
  }

  var cgDegrees: CGFloat {
    return CGFloat(degrees)
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


// MARK: Extend Int to initialize with an Angle instance
extension Int {
  init(_ angle: Angle) {
    self = Int(angle.value)
  }
}

