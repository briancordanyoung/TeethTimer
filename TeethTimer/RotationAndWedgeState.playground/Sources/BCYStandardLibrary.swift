

public func comments(() -> ()) {
    // This is a no-op function created to use the trailing closure syntax
    // to wrap up a bunch of comments for 
}

// See: http://owensd.io/2015/05/12/optionals-if-let.html
public func hasValue<T>(value: T?) -> Bool {
  switch (value) {
    case .Some(_): return true
    case .None: return false
  }
}

public func doesNotHaveValue<T>(value: T?) -> Bool {
  let result = hasValue(value)
  return !result
}