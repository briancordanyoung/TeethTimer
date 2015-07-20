import AVFoundation
import UIKit


extension TimerViewController {
  
  func setupCachedUI() {
    setupCashedUIVideoConstraints()
    setupCachedUIAsset()
  }
  
  func setupCashedUIVideoConstraints() {
    cachedUIVideoView.setTranslatesAutoresizingMaskIntoConstraints(false)
    let layoutAttributes: [NSLayoutAttribute] = [.Leading,
                                                 .Trailing,
                                                 .Top,
                                                 .Bottom]
    
    let contraints = layoutAttributes.map() {
      NSLayoutConstraint(item: self.cachedUIVideoView,
                    attribute: $0,
                    relatedBy: NSLayoutRelation.Equal,
                       toItem: self.view,
                    attribute: $0,
                   multiplier: 1.0,
                     constant: 0.0)
    }
    self.view.addConstraints(contraints)
  }
  
  func urlForCashedUI() -> NSURL? {
    var url: NSURL?
    
    // Look for a movie renderd to the document folder
    url = urlForDocumentAsset(kAppCachedUIMovieBaseNameKey + ".mp4")
    
    // Look for a movie for this device
    if url.hasNoValue {
      url = urlForAppBundleAsset(kAppCachedUIMovieBaseNameKey +
        screenSizeExtention(), ofType: "mp4")
    }
    
    // Look for a genaric movie
    if url.hasNoValue {
      url = urlForAppBundleAsset(kAppCachedUIMovieBaseNameKey, ofType: "mp4")
    }
    
    return url
  }
  
  
  func setupCachedUIAsset() {
    let url = urlFromFunction(urlForCashedUI)
    if let asset = AVURLAsset(URL: url, options: nil) {
      asset.loadValuesAsynchronouslyForKeys( ["tracks"],
        completionHandler: {
          self.setupVideoPlayerWithAsset( asset,
                               videoView: self.cachedUIVideoView,
                      andVideoProperties: self.cachedUIVideo)
          
          self.updateVideoForWheelRotation()
      })
    }
  }

  
}
