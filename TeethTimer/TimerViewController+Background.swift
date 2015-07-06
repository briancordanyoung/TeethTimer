import AVFoundation
import UIKit

struct BackgroundVideoProperties {
  var player: AVPlayer?
  var videoTime = CMTime()
  var asset: AVURLAsset?

  var duration: Int64 {
    return self.videoTime.value
  }
}


extension TimerViewController {

  func setupBackground() {
    setupVideoBackgroundConstraints()
    setupVideoBackgroundAsset()
  }
  
  func currentAssetURL() -> NSURL? {
    var currentURL: NSURL?
    if let asset = backgroundVideo.asset {
      if asset.URL != nil {
        currentURL = asset.URL
      }
    }
    return currentURL
  }

  
  func urlIfItExists(url: NSURL?) -> NSURL? {
    var existingURL: NSURL?
    
    if let url = url {
      if url.checkResourceIsReachableAndReturnError(nil) {
        existingURL = url
      }
    }
    return existingURL
  }
  
  func urlForDocumentAsset(name: String) -> NSURL? {
    let paths = NSFileManager.defaultManager()
      .URLsForDirectory( .DocumentDirectory, inDomains: .UserDomainMask)
    let path = paths.last as? NSURL
    return urlIfItExists(path?.URLByAppendingPathComponent(name))
  }
  
  
  func urlForCashedUI() -> NSURL? {
    var url: NSURL?
    
    url = urlForDocumentAsset(kAppCacheUIMovieBaseNameKey + ".mp4")
    if doesNotHaveValue(url) {
      url = urlForAppBundleAsset(kAppCacheUIMovieBaseNameKey, ofType: "mp4")
    }
    return url
  }
  
  func urlForAppBundleAsset(name: String, ofType type: String) -> NSURL? {
    var url: NSURL?
    var filepath = NSBundle.mainBundle().pathForResource(name, ofType: type)
    if let filepath = filepath {
      url = NSURL.fileURLWithPath(filepath)
    }
    return urlIfItExists(url)
  }

  
  func urlForBackground() -> NSURL? {
    return urlForAppBundleAsset("forward-lg", ofType: "mp4")
  }
  
  

  func newURL() -> NSURL? {
    var newURL: NSURL?
    
    if isCashedUI {
      newURL = urlForCashedUI()
    } else {
      newURL = urlForBackground()
    }
    
    return newURL
  }
  
  
  func setupVideoBackgroundAsset() {
    if let fileURL = newURL() {
      if let currentURL = currentAssetURL() {
        if !fileURL.isEqual(currentURL) {
          setupVideoBackgroundAsset(fileURL)
        }
      } else {
        setupVideoBackgroundAsset(fileURL)
      }
    }
  }
  
  
  func setupVideoBackgroundAsset(fileURL: NSURL) {
    if let asset = AVURLAsset(URL: fileURL, options: nil) {
      asset.loadValuesAsynchronouslyForKeys( ["tracks"],
        completionHandler: {
          self.setupBackgroundVideoPlayer(asset)
      })
    }
  }
  
  func setupBackgroundVideoPlayer(asset: AVURLAsset) {
    let playerItem = AVPlayerItem(asset: asset)
    let player     = AVPlayer(playerItem: playerItem)
    player.allowsExternalPlayback = false
    if let videoLayer = videoView.layer as? AVPlayerLayer {
      
      backgroundVideo.asset     = asset
      backgroundVideo.videoTime = backgroundVideo.asset!.duration
      backgroundVideo.player    = player

      if let gavinWheel = gavinWheel {
        gavinWheelChanged(gavinWheel)
      }
      
      videoLayer.player = player
      player.actionAtItemEnd = .None
    }
  }
  
  
  func updateBackgroundForPercentDone(percent: CGFloat) {
    
    if let backgroundPlayer = backgroundVideo.player {
      
      switch backgroundPlayer.status {
      case .ReadyToPlay:
        seekToTimeByPercentage(percent, inPlayer: backgroundPlayer)
      case .Unknown:
        println("unknown status")
      case .Failed:
        println("failed to play")
      }
    }
  }

  
  
  func seekToTimeByPercentage(percent: CGFloat, inPlayer player: AVPlayer) {
    var wedgeImageCount: Int64 = 1
    if let imageWheelView = imageWheelView {
      wedgeImageCount = Int64(imageWheelView.wedgeSeries.wedgeCount)
    }
    
    let totalFrames       = backgroundVideo.duration
    
    let framesPerWedge    = Int64(CGFloat(totalFrames) / CGFloat(wedgeImageCount))
    let interactiveFrames = totalFrames - framesPerWedge
    let framesPast        = Int64(CGFloat(interactiveFrames) * percent)
    let frame             = interactiveFrames - framesPast + (framesPerWedge / 2)

//    println("time: \(frame.value)")
    
    seekToFrame(frame, inPlayer: player)
  }

  func seekToFrame(frame: Int64, inPlayer player: AVPlayer) {
    let currentFrame = player.currentTime().value
    let currentTime  = backgroundVideo.videoTime
    let seekToFrame  = frame
    
    if currentFrame != frame {
      var nextTime   = currentTime
      nextTime.value = seekToFrame
      seekToTime(nextTime, inPlayer: player)
    }
  }
  
  func seekToTime(time: CMTime, inPlayer player: AVPlayer) {
    player.seekToTime(time, toleranceBefore: kCMTimeZero,
                             toleranceAfter: kCMTimeZero)
  }
  
}
