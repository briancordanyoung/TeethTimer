import Swift

public protocol AngularType : Comparable, FloatLiteralConvertible, IntegerLiteralConvertible, SignedNumberType {
  var value: Double { set get }
  init(_ value: Double)
}

public func % <T:AngularType> (lhs: T, rhs: T) -> T {
  return T(lhs.value % rhs.value)
}

public func + <T:AngularType> (lhs: T, rhs: T) -> T {
  return T(lhs.value + rhs.value)
}

public func - <T:AngularType> (lhs: T, rhs: T) -> T {
  return T(lhs.value - rhs.value)
}

public func < <T:AngularType> (lhs: T, rhs: T) -> Bool {
  return lhs.value < rhs.value
}

public func == <T:AngularType> (lhs: T, rhs: T) -> Bool {
  return lhs.value == rhs.value
}

public prefix func - <T: AngularType> (number: T) -> T {
  return T(-number.value)
}

public func += <T:AngularType> (inout lhs: T, rhs: T) {
  lhs.value = lhs.value + rhs.value
}

public func -= <T:AngularType> (inout lhs: T, rhs: T) {
  lhs.value = lhs.value - rhs.value
}

public func / <T:AngularType> (lhs: T, rhs: T) -> T {
  return T(lhs.value / rhs.value)
}

public func * <T:AngularType> (lhs: T, rhs: T) -> T {
  return T(lhs.value * rhs.value)
}

public func floor<T:AngularType>(x: T) -> T {
  return T(floor(x.value))
}

public func ceil<T:AngularType>(x: T) -> T {
  return T(ceil(x.value))
}

public func log<T:AngularType>(x: T) -> T {
  return T(log(x.value))
}

public func abs<T:AngularType>(x: T) -> T {
  return T(abs(x.value))
}
