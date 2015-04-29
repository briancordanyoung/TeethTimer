import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  var continueTimerWhenEnteringForeground = false
  
  // Anytime the app is brought to the forground, the timer duration preference
  // could have been changed.  Check to see if the timer is currently active
  // (active: paused or counting down, but not already reset and waiting to start)
  // If the timer is not active, then reset the timer so that it reads the new
  // timer duration preference and updates the UI to reflect it.
  //
  // This assumes that the rootViewController is our TimerViewController class
  lazy var timerViewController: TimerViewController = {
    let rootViewController = UIApplication.sharedApplication().keyWindow?.rootViewController
    return rootViewController as! TimerViewController
    }()
  
  func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
    
    // https://stackoverflow.com/questions/26461689/ios-state-restoration-animation-bug/26591842#26591842?newreg=72c20853498146b7a00cc5351ba502c2&newUserTooltips=true
    self.window?.makeKeyAndVisible()
    return true
  }
  
  func application(application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    return true
  }
  
  func applicationWillResignActive(application: UIApplication) {
    if timerViewController.timer.status == TimerStatus.Counting {
      timerViewController.timer.pause()
      continueTimerWhenEnteringForeground = true
    }
  }
  
  func applicationDidEnterBackground(application: UIApplication) {
  }
  
  func applicationWillEnterForeground(application: UIApplication) {
  }
  
  func applicationDidBecomeActive(application: UIApplication) {
    timerViewController.setupAppearenceOfLowerThird()
    if continueTimerWhenEnteringForeground {
      timerViewController.timer.start()
      timerViewController.setupAppearenceOfLowerThird()      
      continueTimerWhenEnteringForeground = false
    }

  }
  
  func applicationWillTerminate(application: UIApplication) {
  }
  
  
  
}

