import AVFoundation

class VideoView: UIView {
  
  override class func layerClass() -> AnyClass {
    return AVPlayerLayer.self
  }
}