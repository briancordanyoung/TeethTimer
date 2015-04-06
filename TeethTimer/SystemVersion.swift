import Foundation

class SystemVersion: NSObject {
  
  class func iOS8AndUp() -> Bool {
    let iOS8AndUp:Bool
    
    switch UIDevice.currentDevice().systemVersion.compare("8.0.0",
                                options: NSStringCompareOptions.NumericSearch) {
      case .OrderedSame, .OrderedDescending:
        iOS8AndUp = true
      case .OrderedAscending:
        iOS8AndUp = false
    }
    return iOS8AndUp
  }
  
  class func iOS7AndBelow() -> Bool {
    return !self.iOS8AndUp()
  }
}