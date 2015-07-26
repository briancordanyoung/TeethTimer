import UIKit

extension AppDelegate {
  
  func registerUserDefaults() {
    let defaults: [String:AnyObject] = [
      kAppUseCachedUIKey:         false,
      kAppBlurLowerThirdKey:      true,
      kAppShowTimeLabelKey:       true,
      kAppChangeWedgePieAngleKey: true,
    ]
    
    NSUserDefaults.standardUserDefaults().registerDefaults(defaults)
  }
  
}
