

func comments(() -> ()) {
    // This is a no-op function created to use the trailing closure syntax
    // to wrap up a bunch of comments for 
}

// See: http://owensd.io/2015/05/12/optionals-if-let.html
//func hasValue<T>(value: T?) -> Bool {
//  switch (value) {
//    case .Some(_): return true
//    case .None: return false
//  }
//}
//
//func doesNotHaveValue<T>(value: T?) -> Bool {
//  let result = hasValue(value)
//  return !result
//}


extension Optional {
 
  var hasValue: Bool {
    get {
      return hasValue(self)
    }
  }
  
  func hasValue<T>(value: T?) -> Bool {
    switch (value) {
    case .Some(_): return true
    case .None:    return false
    }
  }
  
  var hasNoValue: Bool {
    get {
      return hasNoValue(self)
    }
  }

  func hasNoValue<T>(value: T?) -> Bool {
    let result = hasValue(value)
    return !result
  }

}