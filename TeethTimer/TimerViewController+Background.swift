import AVFoundation
import UIKit



extension TimerViewController {

  func setupBackground() {
    setupBackgroundVideoConstraints()
    setupVideoBackgroundAsset()
  }
  
  func setupBackgroundVideoConstraints() {
    let height = NSLayoutConstraint(item: backgroundVideoView,
                               attribute: NSLayoutAttribute.Width,
                               relatedBy: NSLayoutRelation.Equal,
                                  toItem: self.view,
                               attribute: NSLayoutAttribute.Height,
                              multiplier: 1.0,
                                constant: 0.0)
    self.view.addConstraint(height)
    
    let aspect = NSLayoutConstraint(item: backgroundVideoView,
                               attribute: NSLayoutAttribute.Width,
                               relatedBy: NSLayoutRelation.Equal,
                                  toItem: backgroundVideoView,
                               attribute: NSLayoutAttribute.Height,
                              multiplier: 1.0,
                                constant: 0.0)
    backgroundVideoView.addConstraint(aspect)
  }
  
  func urlForBackground() -> NSURL? {
    // Look for a movie for this device
    var url = urlForAppBundleAsset(kAppBGMovieBaseNameKey +
                                          screenSizeExtention(), ofType: "mp4")
    
    // Look for a genaric movie
    if url.hasNoValue {
      url = urlForAppBundleAsset(kAppBGMovieBaseNameKey, ofType: "mp4")
    }
    
    return url
  }
  
  
  func setupVideoBackgroundAsset() {
    let url = urlFromFunction(urlForBackground)
    if let asset = AVURLAsset(URL: url, options: nil) {
      asset.loadValuesAsynchronouslyForKeys( ["tracks"],
        completionHandler: {
          self.setupVideoPlayerWithAsset( asset,
                               videoView: self.backgroundVideoView,
                      andVideoProperties: self.backgroundVideo)
          
          self.updateVideoForWheelRotation()
      })
    }
  }
  
}
