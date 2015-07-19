import AVFoundation
import UIKit

struct CachedUIVideoProperties {
  var player: AVPlayer?
  var videoTime = CMTime()
  var asset: AVURLAsset?
  
  var duration: Int64 {
    return self.videoTime.value
  }
}


extension TimerViewController {
  
  func setupCachedUI() {
    setupCashedUIVideoConstraints()
//    setupCachedUIAsset()
  }
  
  func setupCashedUIVideoConstraints() {
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
  
//  func currentAssetURL() -> NSURL? {
//    var currentURL: NSURL?
//    if let asset = backgroundVideo.asset {
//      if asset.URL != nil {
//        currentURL = asset.URL
//      }
//    }
//    return currentURL
//  }
//  
//  
//  func urlIfItExists(url: NSURL?) -> NSURL? {
//    var existingURL: NSURL?
//    
//    if let url = url {
//      if url.checkResourceIsReachableAndReturnError(nil) {
//        existingURL = url
//      }
//    }
//    return existingURL
//  }
//  
//  func urlForDocumentAsset(name: String) -> NSURL? {
//    let paths = NSFileManager.defaultManager()
//      .URLsForDirectory( .DocumentDirectory, inDomains: .UserDomainMask)
//    let path = paths.last as? NSURL
//    return urlIfItExists(path?.URLByAppendingPathComponent(name))
//  }
//  
//  func screenSizeExtention() -> String {
//    switch Device() {
//    case .iPhone4,
//    .iPhone4s:
//      return "@3.5"
//    case .iPhone5,
//    .iPhone5c,
//    .iPhone5s,
//    .iPodTouch5:
//      return "@4.0"
//    case .iPhone6:
//      return "@4.7"
//    case .Simulator:
//      return "@4.7"
//    default:
//      return ""
//    }
//  }
//  
//  func urlForCashedUI() -> NSURL? {
//    var url: NSURL?
//    
//    // Look for a movie renderd to the document folder
//    url = urlForDocumentAsset(kAppCachedUIMovieBaseNameKey + ".mp4")
//    
//    // Look for a movie for this device
//    if url.hasNoValue {
//      url = urlForAppBundleAsset(kAppCachedUIMovieBaseNameKey +
//        screenSizeExtention(), ofType: "mp4")
//    }
//    
//    // Look for a genaric movie
//    if url.hasNoValue {
//      url = urlForAppBundleAsset(kAppCachedUIMovieBaseNameKey, ofType: "mp4")
//    }
//    
//    return url
//  }
//  
//  func urlForAppBundleAsset(name: String, ofType type: String) -> NSURL? {
//    var url: NSURL?
//    var filepath = NSBundle.mainBundle().pathForResource(name, ofType: type)
//    if let filepath = filepath {
//      url = NSURL.fileURLWithPath(filepath)
//    }
//    return urlIfItExists(url)
//  }
//  
//  
//  func urlForBackground() -> NSURL? {
//    // Look for a movie for this device
//    var url = urlForAppBundleAsset(kAppBGMovieBaseNameKey +
//      screenSizeExtention(), ofType: "mp4")
//    
//    // Look for a genaric movie
//    if url.hasNoValue {
//      url = urlForAppBundleAsset(kAppBGMovieBaseNameKey, ofType: "mp4")
//    }
//    
//    return url
//  }
//  
//  
//  
//  func newURL() -> NSURL? {
//    var newURL: NSURL?
//    
//    if isCashedUI {
//      newURL = urlForCashedUI()
//    } else {
//      newURL = urlForBackground()
//    }
//    
//    return newURL
//  }
//  
//  
//  func setupVideoBackgroundAsset() {
//    if let fileURL = newURL() {
//      if let currentURL = currentAssetURL() {
//        if !fileURL.isEqual(currentURL) {
//          setupVideoBackgroundAsset(fileURL)
//        }
//      } else {
//        setupVideoBackgroundAsset(fileURL)
//      }
//    }
//  }
//  
//  
//  func setupVideoBackgroundAsset(fileURL: NSURL) {
//    if let asset = AVURLAsset(URL: fileURL, options: nil) {
//      asset.loadValuesAsynchronouslyForKeys( ["tracks"],
//        completionHandler: {
//          self.setupBackgroundVideoPlayer(asset)
//      })
//    }
//  }
//  
//  func setupBackgroundVideoPlayer(asset: AVURLAsset) {
//    let playerItem = AVPlayerItem(asset: asset)
//    let player     = AVPlayer(playerItem: playerItem)
//    player.allowsExternalPlayback = false
//    if let videoLayer = backgroundVideoView.layer as? AVPlayerLayer {
//      
//      
//      
//      backgroundVideo.asset     = asset
//      backgroundVideo.videoTime = backgroundVideo.asset!.duration
//      backgroundVideo.player    = player
//      
//      if let gavinWheel = gavinWheel {
//        wheelRotated(gavinWheel)
//      }
//      
//      videoLayer.player = player
//      videoLayer.videoGravity = AVLayerVideoGravityResize
//      Async.main() {
//        println("Video Layer Frame \(videoLayer.frame)")
//        println("Video Layer Bounds \(videoLayer.bounds)")
//      }
//      player.actionAtItemEnd = .None
//    }
//  }
//  
//  
//  func updateBackgroundForPercentDone(percent: CGFloat) {
//    
//    if let backgroundPlayer = backgroundVideo.player {
//      
//      switch backgroundPlayer.status {
//      case .ReadyToPlay:
//        seekToTimeByPercentage(percent, inPlayer: backgroundPlayer)
//      case .Unknown:
//        println("unknown status")
//      case .Failed:
//        println("failed to play")
//      }
//    }
//  }
//  
//  
//  
//  func seekToTimeByPercentage(percent: CGFloat, inPlayer player: AVPlayer) {
//    var wedgeImageCount: Int64 = 1
//    if let imageWheelView = imageWheelView {
//      wedgeImageCount = Int64(imageWheelView.wedgeSeries.wedgeCount)
//    }
//    
//    let totalFrames       = backgroundVideo.duration
//    
//    let framesPerWedge    = Int64(CGFloat(totalFrames) / CGFloat(wedgeImageCount))
//    let interactiveFrames = totalFrames - framesPerWedge
//    let framesPast        = Int64(CGFloat(interactiveFrames) * percent)
//    let frame             = interactiveFrames - framesPast + (framesPerWedge / 2)
//    
//    //    println("time: \(frame)")
//    
//    seekToFrame(frame, inPlayer: player)
//  }
//  
//  func seekToFrame(frame: Int64, inPlayer player: AVPlayer) {
//    let currentFrame = player.currentTime().value
//    let currentTime  = backgroundVideo.videoTime
//    let seekToFrame  = frame
//    
//    if currentFrame != frame {
//      var nextTime   = currentTime
//      nextTime.value = seekToFrame
//      seekToTime(nextTime, inPlayer: player)
//    }
//  }
//  
//  func seekToTime(time: CMTime, inPlayer player: AVPlayer) {
//    player.seekToTime(time, toleranceBefore: kCMTimeZero,
//      toleranceAfter: kCMTimeZero)
//  }
  
}
