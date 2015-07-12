import UIKit

public typealias Rotation = AccumulatedAngle
// MARK: AccumulatedAngle - A number that represents an angle in both 
//                          degrees or radians.
public struct AccumulatedAngle: AngularType, Printable {
  
  public var value: Double
  
  public init(_ value: Double) {
    self.value = value
  }
  
  
  // All other initilizers call the above init()
  public init(_ accumulatedAngle: AccumulatedAngle) {
    self.init(Double(accumulatedAngle.value))
  }
  
  public init(_ angle: Angle) {
    self.init(Double(angle.value))
  }
  
  public init(_ value: CGFloat) {
    self.init(Double(value))
  }
  
  public init(_ value: Int) {
    self.init(Double(value))
  }
  
  public init(radians: Double) {
    self.init(radians)
  }
  
  public init(radians: CGFloat) {
    self.init(Double(radians))
  }
  
  public init(radians: Int) {
    self.init(Double(radians))
  }
  
  
  public init(degrees: Double) {
    self.init(radians: Angle.degrees2radians(degrees))
  }
  
  public init(degrees: CGFloat) {
    self.init(degrees: Double(degrees))
  }
  
  public init(degrees: Int) {
    self.init(degrees: Double(degrees))
  }
  
  public var radians: Double  {
    return value
  }
  
  public var degrees: Double {
    return Angle.radians2Degrees(value)
  }
  
  public var angle: Angle {
    return Angle(radians)
  }
  
  public var description: String {
    return "\(value)"
  }
  
}

// Convenience Computed Properties to convert to CGFloat
extension AccumulatedAngle  {
  public var cgRadians: CGFloat  {
    return CGFloat(radians)
  }
  
  public var cgDegrees: CGFloat {
    return CGFloat(degrees)
  }
}


// MARK: Protocol Conformance
extension AccumulatedAngle: IntegerLiteralConvertible {
  public init(integerLiteral: IntegerLiteralType) {
    self.init(Double(integerLiteral))
  }
}

extension AccumulatedAngle: FloatLiteralConvertible {
  public init(floatLiteral: FloatLiteralType) {
    self.init(Double(floatLiteral))
  }
}


// MARK: Extend Int to initialize with an AccumulatedAngle
extension Int {
  public init(_ accumulatedAngle: AccumulatedAngle) {
    self = Int(accumulatedAngle.radians)
  }
}


extension AccumulatedAngle {
  public static var pi: AccumulatedAngle {
//    return AccumulatedAngle(Revolution.preset(.pi))
    return AccumulatedAngle(M_PI)
  }

  public static var tau: AccumulatedAngle {
//    return AccumulatedAngle(Revolution.preset(.tau))
    return AccumulatedAngle(M_PI * 2)
  }

  public static var full: AccumulatedAngle {
//    return AccumulatedAngle(Revolution.preset(.full))
    return AccumulatedAngle(M_PI * 2)
  }

  public static var half: AccumulatedAngle {
//    return AccumulatedAngle(Revolution.preset(.half))
    return AccumulatedAngle(M_PI)
  }

  public static var quarter: AccumulatedAngle {
//    return AccumulatedAngle(Revolution.preset(.quarter))
    return AccumulatedAngle(M_PI * 0.50)
  }

  public static var threeQuarter: AccumulatedAngle {
//    return AccumulatedAngle(Revolution.preset(.threeQuarter))
    return AccumulatedAngle(M_PI * 1.50)
  }
}




// MARK: AccumulatedAngle & Angle specific overloads

public func % (lhs: AccumulatedAngle, rhs: Angle) -> AccumulatedAngle {
  return AccumulatedAngle(lhs.value % rhs.value)
}


public func + (lhs: Angle, rhs: AccumulatedAngle) -> AccumulatedAngle {
  return AccumulatedAngle(lhs.value + rhs.value)
}

public func - (lhs: Angle, rhs: AccumulatedAngle) -> AccumulatedAngle {
  return AccumulatedAngle(lhs.value - rhs.value)
}

public func + (lhs: AccumulatedAngle, rhs: Angle) -> AccumulatedAngle {
  return AccumulatedAngle(lhs.value + rhs.value)
}

public func - (lhs: AccumulatedAngle, rhs: Angle) -> AccumulatedAngle {
  return AccumulatedAngle(lhs.value - rhs.value)
}



public func < (lhs: Angle, rhs: AccumulatedAngle) -> Bool {
  return lhs.value < rhs.value
}

public func == (lhs: Angle, rhs: AccumulatedAngle) -> Bool {
  return lhs.value == rhs.value
}

public func < (lhs: AccumulatedAngle, rhs: Angle) -> Bool {
  return lhs.value < rhs.value
}

public func == (lhs: AccumulatedAngle, rhs: Angle) -> Bool {
  return lhs.value == rhs.value
}



public func += (inout lhs: AccumulatedAngle, rhs: Angle) {
  lhs.value = lhs.value + rhs.value
}

public func -= (inout lhs: AccumulatedAngle, rhs: Angle) {
  lhs.value = lhs.value - rhs.value
}

public func / (lhs: AccumulatedAngle, rhs: Angle) -> AccumulatedAngle {
  return AccumulatedAngle(lhs.value / rhs.value)
}

public func * (lhs: AccumulatedAngle, rhs: Angle) -> AccumulatedAngle {
  return AccumulatedAngle(lhs.value * rhs.value)
}




// MARK: AccumulatedAngle & Int specific overloads

public func % (lhs: AccumulatedAngle, rhs: Int) -> AccumulatedAngle {
  return AccumulatedAngle(lhs.value % Double(rhs))
}


func + (lhs: Int, rhs: AccumulatedAngle) -> AccumulatedAngle {
  return AccumulatedAngle(Double(lhs) + rhs.value)
}

func - (lhs: Int, rhs: AccumulatedAngle) -> AccumulatedAngle {
  return AccumulatedAngle(Double(lhs) - Double(rhs.value))
}

func + (lhs: AccumulatedAngle, rhs: Int) -> AccumulatedAngle {
  return AccumulatedAngle(lhs.value + Double(rhs))
}

func - (lhs: AccumulatedAngle, rhs: Int) -> AccumulatedAngle {
  return AccumulatedAngle(lhs.value - Double(rhs))
}



func < (lhs: Int, rhs: AccumulatedAngle) -> Bool {
  return Double(lhs) < rhs.value
}

func == (lhs: Int, rhs: AccumulatedAngle) -> Bool {
  return Double(lhs) == rhs.value
}

func < (lhs: AccumulatedAngle, rhs: Int) -> Bool {
  return lhs.value < Double(rhs)
}

func == (lhs: AccumulatedAngle, rhs: Int) -> Bool {
  return lhs.value == Double(rhs)
}



func += (inout lhs: AccumulatedAngle, rhs: Int) {
  lhs.value = lhs.value + Double(rhs)
}

func -= (inout lhs: AccumulatedAngle, rhs: Int) {
  lhs.value = lhs.value - Double(rhs)
}

func / (lhs: AccumulatedAngle, rhs: Int) -> AccumulatedAngle {
  return AccumulatedAngle(lhs.value / Double(rhs))
}

func * (lhs: AccumulatedAngle, rhs: Int) -> AccumulatedAngle {
  return AccumulatedAngle(lhs.value * Double(rhs))
}


