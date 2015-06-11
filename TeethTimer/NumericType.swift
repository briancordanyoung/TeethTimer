import Swift

public protocol NumericType : Comparable, FloatLiteralConvertible, IntegerLiteralConvertible, SignedNumberType {
  var value: Double { set get }
  init(_ value: Double)
}

public func % <T :NumericType> (lhs: T, rhs: T) -> T {
  return T(lhs.value % rhs.value)
}

public func + <T :NumericType> (lhs: T, rhs: T) -> T {
  return T(lhs.value + rhs.value)
}

public func - <T :NumericType> (lhs: T, rhs: T) -> T {
  return T(lhs.value - rhs.value)
}

public func < <T :NumericType> (lhs: T, rhs: T) -> Bool {
  return lhs.value < rhs.value
}

public func == <T :NumericType> (lhs: T, rhs: T) -> Bool {
  return lhs.value == rhs.value
}

public prefix func - <T: NumericType> (number: T) -> T {
  return T(-number.value)
}

public func += <T :NumericType> (inout lhs: T, rhs: T) {
  lhs.value = lhs.value + rhs.value
}

public func -= <T :NumericType> (inout lhs: T, rhs: T) {
  lhs.value = lhs.value - rhs.value
}

public func / <T :NumericType> (lhs: T, rhs: T) -> T {
  return T(lhs.value / rhs.value)
}

public func * <T :NumericType> (lhs: T, rhs: T) -> T {
  return T(lhs.value * rhs.value)
}

