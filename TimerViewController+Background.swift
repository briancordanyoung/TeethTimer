import AVFoundation
import UIKit

struct BackgroundVideoProperties {
  var player: AVPlayer?
  var videoTime = CMTime()
  var asset: AVAsset?

  var duration: Int64 {
    return self.videoTime.value
  }
}


extension TimerViewController {

  func setupBackground() {
    setupVideoBackgroundConstraints()
    setupVideoBackgroundAsset()
  }
  
  
  func setupVideoBackgroundAsset() {
    
    var filepath = NSBundle.mainBundle().pathForResource("forward", ofType: "m4v")
    assert(filepath != nil,"Background movie file does not exist in main bundle")
    
    if let filepath = filepath {
      let fileURL = NSURL.fileURLWithPath(filepath)
      
      if let asset = AVURLAsset(URL: fileURL, options: nil) {
        asset.loadValuesAsynchronouslyForKeys( ["tracks"],
          completionHandler: {
            self.backgroundVideo.asset = asset
            self.setupBackgroundVideoQueuePlayer()
        })
      }
    }
  }
  
  
  func setupBackgroundVideoQueuePlayer() {
    let forwardDuration = backgroundVideo.asset!.duration.value
    backgroundVideo.videoTime = backgroundVideo.asset!.duration
    
    let playerItem = AVPlayerItem(asset: backgroundVideo.asset)
    let player     = AVPlayer(playerItem: playerItem)
    player.allowsExternalPlayback = false
    let videoLayer = videoView.layer as? AVPlayerLayer
    videoLayer?.player = player
    player.actionAtItemEnd = .None
    
    backgroundVideo.player = player
    seekToTimeByPercentage(0.0, inPlayer: player)
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
    var wheelCount: Int64 = 1
    if let imageWheelView = imageWheelView {
      wheelCount = Int64(imageWheelView.images.count)
    }
    
    var seekToTime    = backgroundVideo.videoTime
    let totalFrames   = backgroundVideo.duration
    let wedgeDuration = Int64(CGFloat(totalFrames) / CGFloat(wheelCount))
    let interactiveFrames = totalFrames - (wedgeDuration * 2)
    let framesPast    = Int64(CGFloat(interactiveFrames) * percent)
    let frame         = interactiveFrames - framesPast + wedgeDuration
    
    let currentFrame = player.currentTime().value
    
    let seekToFrame = frame
  
    if currentFrame != seekToFrame {
      
      seekToTime.value = seekToFrame
      player.seekToTime(seekToTime, toleranceBefore: kCMTimeZero,
                                     toleranceAfter: kCMTimeZero)
    }
  }
  
}
