import AVFoundation
import UIKit

struct BackgroundVideoProperties {
  var player: AVQueuePlayer?
  var videoTime = CMTime()
  var assets: (forward: AVAsset?, reverse: AVAsset?)

  var videoDuration: Int64 {
    return self.videoTime.value
  }
}


extension TimerViewController {

  func setupVideoBackgroundAsset(direction: DirectionRotated) {
    
    let filepath: String?
    switch direction {
    case .Clockwise:
      filepath = NSBundle.mainBundle().pathForResource("forward", ofType: "m4v")
    case .CounterClockwise:
      filepath = NSBundle.mainBundle().pathForResource("reverse", ofType: "m4v")
    }
    
    assert(filepath != nil,"Background movie file does not exist in main bundle")
    
    if let filepath = filepath {
      let fileURL = NSURL.fileURLWithPath(filepath)
      
      if let asset = AVURLAsset(URL: fileURL, options: nil) {
        asset.loadValuesAsynchronouslyForKeys( ["tracks"],
          completionHandler: {
            self.rememberAsset(asset, forDirection: direction)
        })
      }
    }
  }
  
  func rememberAsset(asset: AVURLAsset,
    forDirection direction: DirectionRotated) {
      
      switch direction {
      case .Clockwise:
        backgroundAssets.forward = asset
      case .CounterClockwise:
        backgroundAssets.reverse = asset
      }
      
      if backgroundAssets.forward != nil &&
        backgroundAssets.reverse != nil {
          
          setupBackgroundVideoQueuePlayer()
      }
  }
  
  func setupBackgroundVideoQueuePlayer() {
    let reverseDuration = backgroundAssets.reverse!.duration.value
    let forwardDuration = backgroundAssets.forward!.duration.value
    let message = "Both background movies must have the same number of frames."
    assert(forwardDuration == reverseDuration, message)
    backgroundVideoTime = backgroundAssets.forward!.duration
    
    var playerItems: [AVPlayerItem] = []
    for i in 1...6 {
      if i % 2 == 0 {
        let playerItem = AVPlayerItem(asset: backgroundAssets.reverse!)
        playerItems.append(playerItem)
      } else {
        let playerItem = AVPlayerItem(asset: backgroundAssets.forward!)
        playerItems.append(playerItem)
      }
    }
    
    let player     = AVQueuePlayer(items: playerItems)
    player.allowsExternalPlayback = false
    let videoLayer = videoView.layer as? AVPlayerLayer
    videoLayer?.player = player
    player.actionAtItemEnd = .None
    
    backgroundPlayer = player
    seekToTimeByPercentage(0.0, inPlayer: player)
  }

  func updateBackgroundForPercentDone(percent: CGFloat) {
    if let backgroundPlayer = backgroundPlayer {
      
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

  func seekToTimeByPercentage(percent: CGFloat, inPlayer player: AVQueuePlayer) {
    var wheelCount: Int64 = 1
    if let imageWheelView = imageWheelView {
      wheelCount = Int64(imageWheelView.images.count)
    }
    
    var seekToTime    = backgroundVideoTime
    let totalFrames   = backgroundVideoDuration
    let wedgeDuration = Int64(CGFloat(totalFrames) / CGFloat(wheelCount))
    let interactiveFrames = totalFrames - (wedgeDuration * 2)
    let framesPast    = Int64(CGFloat(interactiveFrames) * percent)
    let frame         = interactiveFrames - framesPast + wedgeDuration
    let frameRev      = totalFrames - frame
    
    
    let currentFrame = player.currentTime().value

    var directionMsg = "    "
    var switchMovies = false
    var playerItem: AVPlayerItem?
    if let movieName = currentMovieName(player) {
      var name = movieName
      switch name {
        case "forward":
          if currentFrame < frame {
            directionMsg = "<-- "
            switchMovies = true
            name = "reverse"
            playerItem = AVPlayerItem(asset: backgroundAssets.reverse!)
          }
        case "reverse":
          if currentFrame < frameRev {
            directionMsg = "--> "
            switchMovies = true
            name = "forward"
            playerItem = AVPlayerItem(asset: backgroundAssets.forward!)
          }
        default:
          assertionFailure("Background Movie direction is undetermianed")
      }
      
      let seekToFrame: Int64
      if name == "forward" {
        seekToFrame = frame
      } else {
        seekToFrame = frameRev
      }
      
      if currentFrame != seekToFrame {
//        println("\(directionMsg) \(currentFrame) \(seekToFrame)")
        seekToTime.value = seekToFrame

        if switchMovies { player.advanceToNextItem() }
        player.seekToTime(seekToTime, toleranceBefore: kCMTimeZero,
                                       toleranceAfter: kCMTimeZero)
        if let playerItem = playerItem {
          player.insertItem(playerItem, afterItem: nil)
        }
      }
    }

  }
  
  func currentMovieName(player: AVQueuePlayer) -> String? {
    var name: String?
    
    let url: NSURL? = player.currentItem.asset.valueForKey("URL") as? NSURL
    if let url = url {
      if let nameWithExt: AnyObject = url.pathComponents?.last {
        let nameString = nameWithExt as? String
        name = nameString?.stringByDeletingPathExtension
      }
    }
    
    return name
  }

}
