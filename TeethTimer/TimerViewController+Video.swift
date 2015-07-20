import AVFoundation
import UIKit

final class VideoProperties {
  var player: AVPlayer?
  var videoTime = CMTime()
  var asset: AVURLAsset?
  var videoGravity = AVLayerVideoGravityResize
  
  var duration: Int64 {
    return self.videoTime.value
  }
}


extension TimerViewController {
  
  
  // MARK: -
  // MARK: Setup
  func setupVideoPlayerWithAsset(asset: AVURLAsset,
                             videoView: VideoView,
    andVideoProperties videoProperties: VideoProperties) {
      
    let playerItem = AVPlayerItem(asset: asset)
    let player     = AVPlayer(playerItem: playerItem)
    player.allowsExternalPlayback = false
      
    if let videoLayer = videoView.layer as? AVPlayerLayer {
      
      videoProperties.asset     = asset
      videoProperties.videoTime = videoProperties.asset!.duration
      videoProperties.player    = player
      videoLayer.player         = player
      videoLayer.videoGravity   = videoProperties.videoGravity
      player.actionAtItemEnd    = .None
    }
  }
  
  
  // MARK: -
  // MARK: Change Current Movie Frame
  func updateVideoForPercentDone(percent: CGFloat,
     withVideoProperties videoProperties: VideoProperties) {
    
    if let player = videoProperties.player {
      
      switch player.status {
      case .ReadyToPlay:
        seekToTimeByPercentage(percent, withVideoProperties: videoProperties)
      case .Unknown:
        break //println("unknown status")
      case .Failed:
        println("failed to play")
      }
      
    }
  }

  func seekToTimeByPercentage(percent: CGFloat,
       withVideoProperties properties: VideoProperties) {
    
    if let player = properties.player {
      var wedgeImageCount: Int64 = 1
      if let imageWheelView = imageWheelView {
        wedgeImageCount = Int64(imageWheelView.wedgeSeries.wedgeCount)
      }
      
      let totalFrames       = properties.duration
      
      let framesPerWedge    = Int64(CGFloat(totalFrames) / CGFloat(wedgeImageCount))
      let interactiveFrames = totalFrames - framesPerWedge
      let framesPast        = Int64(CGFloat(interactiveFrames) * percent)
      let frame             = interactiveFrames - framesPast + (framesPerWedge / 2)

  //    println("time: \(frame)")
      
      seekToFrame(frame, withVideoProperties: properties)
    }
  }

  func seekToFrame(             frame: Int64,
       withVideoProperties properties: VideoProperties) {
        
    if let player = properties.player {
      let currentFrame = player.currentTime().value
      let currentTime  = properties.videoTime
      let seekToFrame  = frame
      
      if currentFrame != frame {
        var nextTime   = currentTime
        nextTime.value = seekToFrame
        seekToTime(nextTime, inPlayer: player)
      }
    }
  }

  
  // MARK: -
  // MARK: URL Construction Methods
  
  func urlFromFunction(urlFunction: () -> NSURL?) -> NSURL {
    
    if let url = urlFunction() {
      return url
    } else {
      // TODO: Add Error handling
      assertionFailure("Could Not Find Video Asset.")
      return NSURL()
    }
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
  
  func urlForAppBundleAsset(name: String, ofType type: String) -> NSURL? {
    var url: NSURL?
    var filepath = NSBundle.mainBundle().pathForResource(name, ofType: type)
    if let filepath = filepath {
      url = NSURL.fileURLWithPath(filepath)
    }
    return urlIfItExists(url)
  }

  func screenSizeExtentionByWindowHeight()  -> String {
    let size = UIScreen.mainScreen().bounds.size
    let height = max(size.height,size.width)

    switch height {
    case 480: // iPhone4
      return "@3.5"
    case 568: // iPhone5
      return "@4.0"
    case 667: // iPhone6
      return "@4.7"
    case 736: // iPhone6+
      return ""
    default:
      return ""
    }
  }
  
  func screenSizeExtention() -> String {
    switch Device() {
    case .iPhone4,
         .iPhone4s:
      return "@3.5"
    case .iPhone5,
         .iPhone5c,
         .iPhone5s,
         .iPodTouch5:
      return "@4.0"
    case .iPhone6:
      return "@4.7"
    case .iPhone6Plus:
      return ""
    case .Simulator:
      return screenSizeExtentionByWindowHeight()
    default:
      return ""
    }
  }
  
  
  // MARK: Utilities
  func seekToTime(time: CMTime, inPlayer player: AVPlayer) {
    player.seekToTime(time, toleranceBefore: kCMTimeZero,
                             toleranceAfter: kCMTimeZero)
  }

  func updateVideoForWheelRotation() {
    if let gavinWheel = gavinWheel {
      dispatch_async(dispatch_get_main_queue()) {
        self.wheelRotated(gavinWheel)
      }
    }
  }
  
  
}
