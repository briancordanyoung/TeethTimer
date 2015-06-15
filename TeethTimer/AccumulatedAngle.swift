import Foundation


// MARK: AccumulatedAngle - A number that represents an angle in both 
//                          degrees or radians.
struct AccumulatedAngle: NumericType {
  
  var value: Double
  
  init(_ value: Double) {
    self.value = value
  }
  
  
  // All other initilizers call the above init()
  init(_ value: CGFloat) {
    self.init(Double(value))
  }
  
  init(_ value: Int) {
    self.init(Double(value))
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
}

// Convenience Computed Properties to convert to CGFloat
extension AccumulatedAngle  {
  var cgRadians: CGFloat  {
    return CGFloat(radians)
  }
  
  var cgDegrees: CGFloat {
    return CGFloat(degrees)
  }
}


// MARK: Protocol Conformance
extension AccumulatedAngle: IntegerLiteralConvertible {
  init(integerLiteral: IntegerLiteralType) {
    self.init(Double(integerLiteral))
  }
}

extension AccumulatedAngle: FloatLiteralConvertible {
  init(floatLiteral: FloatLiteralType) {
    self.init(Double(floatLiteral))
  }
}


// MARK: Extend Int to initialize with an AccumulatedAngle
extension Int {
  init(_ accumulatedAngle: AccumulatedAngle) {
    self = Int(accumulatedAngle.radians)
  }
}

