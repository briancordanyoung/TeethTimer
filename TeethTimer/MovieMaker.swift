import AVFoundation
import UIKit

let kAppCacheUIMovieBaseNameKey = "TeethTimer"

class MovieMaker {
  
  var frameTime = CMTimeMake(1, 60)
  let videoSettings: [NSObject:AnyObject]
  
  lazy var assetWriter:   AVAssetWriter = {
    var error: NSError?
    
    let assetWriter = AVAssetWriter(URL: self.movieURL,
      fileType: AVFileTypeQuickTimeMovie,
      error: &error)
    if let error = error {
      NSLog("Error: \(error.debugDescription)")
    }
    
    assert(assetWriter.canAddInput(self.writerInput),
      "AssetWriter could not assept input")
    assetWriter.addInput(self.writerInput)
    
    return assetWriter
    }()
  
  lazy var movieURL: NSURL = {
    var url: NSURL?
    let paths = NSFileManager.defaultManager()
      .URLsForDirectory( .DocumentDirectory, inDomains: .UserDomainMask)
    let path = paths.last as? NSURL
    
    if let path = path {
      let movieName   = kAppCacheUIMovieBaseNameKey + ".mp4"
      url = path.URLByAppendingPathComponent(movieName)
    }
    
    assert(url != nil, "Could not create output movie path.")
    
    println(url!)
    
    return url!
    }()
  
  lazy var writerInput:   AVAssetWriterInput = {
    var writerInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo,
                                    outputSettings: self.videoSettings)
    
    writerInput.expectsMediaDataInRealTime = false
    return writerInput
    }()
  
  
  lazy var bufferAdapter: AVAssetWriterInputPixelBufferAdaptor = {
    let pixelFormatType: NSNumber = kCVPixelFormatType_32ARGB
    let bufferAttributes: [NSObject: AnyObject] =
                             [kCVPixelBufferPixelFormatTypeKey: pixelFormatType]
    
    let bufferAdapter = AVAssetWriterInputPixelBufferAdaptor(
      assetWriterInput: self.writerInput,
      sourcePixelBufferAttributes: bufferAttributes)
    return bufferAdapter
    }()
  
  
  init( settings: [NSObject : AnyObject]) {
    videoSettings = settings
    if let newFrameTime = CMTimeFromSettings(settings) {
      frameTime = newFrameTime
    }
    
    let sideEffectsAreBadBufferAdapter = bufferAdapter
    
    assetWriter.startWriting()
    assetWriter.startSessionAtSourceTime(kCMTimeZero)
  }
  
  func CMTimeFromSettings(settings: [NSObject : AnyObject]) -> CMTime? {
    var time: CMTime?
    
    if let compressionProperties =
          settings[AVVideoCompressionPropertiesKey] as? [NSObject : AnyObject] {
      if let frameRate =
              compressionProperties[AVVideoExpectedSourceFrameRateKey] as? Int {
        time =  CMTimeMake(1, Int32(frameRate))
      }
    }
    
    return time
  }
}