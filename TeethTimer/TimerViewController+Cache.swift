import AVFoundation
import UIKit

extension TimerViewController {
  
  func setupViewsBeforeRendering() {
    startPauseButton.hidden = true
    resetButton.hidden      = true
    timerLabel.hidden       = true
    cacheUIButton.hidden  = true
  }
  
  func resetViewsAfterRendering() {
    self.startPauseButton.hidden     = false
    self.resetButton.hidden          = false
    self.timerLabel.hidden           = false
    self.cacheUIButton.hidden      = false
    self.cacheState.completionHandler = {}
  }
  

  
  // Method used to start the process of rendering and saving the UI
  func cacheUI() {
    if cacheState.hasNotBegun {
      if let gavinWheel = gavinWheel, imageWheelView = imageWheelView {
        setupViewsBeforeRendering()
        setupCacheStateWith(gavinWheel, AndImageWheel: imageWheelView)
      } else {
        // Can't find the views needed to render!
      }
    }
  }
  
  func setupCacheStateWith(wheelControl: WheelControl,
              AndImageWheel imageWheel: ImageWheel) {
    
    cacheState.completionHandler = resetViewsAfterRendering

    let wedgeWidthAngle     = imageWheel.wedgeWidthAngle
    let halfWedgeWidthAngle = wedgeWidthAngle / 2
    let workingRange        = (start: wheelControl.maximumRotation!,
                                 end: wheelControl.minimumRotation!)
                
    // The complete range (in radians) from the farthest point in each direction
    // the wheelControl may rotate.  Including the half a wedge width past
    // the minimum and maximum rotation points when dampening completely stops
    // the rotation.
    let range = expandRange(workingRange, ByAmount: halfWedgeWidthAngle)
    let radiansInRange  = abs(range.start - range.end)
    let degreesInRange  = Circle().radian2Degree(radiansInRange)
    let framesPerDegree = CGFloat(4)
    
    cacheState.startingRotation = range.start
    cacheState.endingRotation   = range.end
    cacheState.totalFrames      = Int(degreesInRange * framesPerDegree)
    cacheState.currentFrame     = 1
    
    wheelControl.rotationAngle = cacheState.currentRotation
    
    cacheState.timer = NSTimer.scheduledTimerWithTimeInterval( 0.1,
                                      target: self,
                                    selector: Selector("checkStateAndContinue"),
                                    userInfo: nil,
                                     repeats: true)
  }
  
  
  func checkStateAndContinue() {
    if (cacheState.isComplete && assetWriterIsNotProcessing()) {
      finishWritingMovie()
    } else {
      checkForNextStage()
    }
  }
  
  func assetWriterIsNotProcessing() -> Bool {
    var writerReady = true
    if let writerInput = cacheState.movieMaker?.writerInput {
      if writerInput.readyForMoreMediaData {
        writerReady = true
      } else {
        writerReady = false
      }
    }
    return writerReady
  }
  
  func checkForNextStage() {
    
    switch cacheState.frameState {
      
      case .idle:
        renderViews()
      
      case .rendered(let image):
        // TODO: put on background thread
        // Async.main() {
        // self.writeFrame(image)
        self.writeFrameToMovie(image)
        // }

      case .writing:
        // Do nothing. We are waiting until writing is done and
        // ready for another image.
        break
    }
  }
  
  
  func renderViews() {
    var image = takeSnapshotOfView(self.view, WithResolutionScale: CGFloat(2.0))
    cacheState.frameState = .rendered(image)
  }
  
  
  func setupMovieMaker() {

    let videoCompressionSettings: [NSObject : AnyObject] = [
               AVVideoAverageBitRateKey : Int(10500000 * 15),
      AVVideoExpectedSourceFrameRateKey : Int(60),
                 AVVideoProfileLevelKey : AVVideoProfileLevelH264MainAutoLevel,
          AVVideoMaxKeyFrameIntervalKey : Int(3),
    ]
    
    let videoSettings: [NSObject : AnyObject] = [
                        AVVideoCodecKey : AVVideoCodecH264,
                        AVVideoWidthKey : self.view.frame.width * 2,
                       AVVideoHeightKey : self.view.frame.height * 2,
        AVVideoCompressionPropertiesKey : videoCompressionSettings,
    ]
    
    cacheState.movieMaker = MovieMaker(settings: videoSettings)
  }
  
  
  func writeFrameToMovie(image: UIImage) {
    
    if doesNotHaveValue(cacheState.movieMaker) {
      setupMovieMaker()
    }
    
    if let movieMaker = cacheState.movieMaker {
      if movieMaker.writerInput.readyForMoreMediaData {
        cacheState.frameState = .writing
        
        let sampleBuffer = BDYMovieMakerHelper.newPixelBufferFromImage(image)

        if sampleBuffer != nil {
          let sampleBufferRef = sampleBuffer.takeRetainedValue()

          let time = currentFrameCMTime(movieMaker)
          movieMaker.bufferAdapter.appendPixelBuffer( sampleBufferRef,
                                withPresentationTime: time)
          
          finishedWritingFrame()
        }
      }
    }
  }
  
  
  func currentFrameCMTime(movieMaker: MovieMaker) -> CMTime {
    let i = cacheState.currentFrame - 1
    
    let presentTime: CMTime
    if (i == 0) {
      presentTime  = kCMTimeZero
    } else {
      let lastTime = CMTimeMake(Int64(i), movieMaker.frameTime.timescale)
      presentTime  = CMTimeAdd( lastTime, movieMaker.frameTime)
    }
    return presentTime
  }
  
  func writeFrameToPNG(image: UIImage) {
    // TODO: Save on background thread
    cacheState.frameState = .writing
    
    if let path = urlForFrame() {
      let png = UIImagePNGRepresentation(image)
      if png != nil {
        png.writeToURL(path, atomically: true)
      }
    } else {
      println("Error: Could not generate file path for frame")
    }
    finishedWritingFrame()
  }
  
  func finishedWritingFrame() {
    cacheState.currentFrame += 1
    gavinWheel?.rotationAngle = cacheState.currentRotation
    cacheState.frameState = .idle
  }
  
  func finishWritingMovie() {
    cacheState.movieMaker?.writerInput.markAsFinished()
    cacheState.movieMaker?.assetWriter.finishWritingWithCompletionHandler() {
      self.tearDownAndResetCacheState()
    }
  }
  
  func tearDownAndResetCacheState() {
    cacheState.timer?.invalidate()
    cacheState.completionHandler()
    cacheState = CacheWheelState()
  }
  
  // Helpers
  func urlForFrame() -> NSURL? {
    var url: NSURL?
    
    let frameNumber = cacheState.currentFrame
    
    let paths = NSFileManager.defaultManager()
      .URLsForDirectory( .DocumentDirectory, inDomains: .UserDomainMask)
    let path = paths.last as? NSURL
    
    if let path = path {
      if (frameNumber == 1) { println(path) }
      let frameString = cacheState.pad(frameNumber)
      let frameName   = "gavinWheel-\(frameString).png"
      url = path.URLByAppendingPathComponent(frameName)
      println(frameString)
    }
    
    return url
  }

  private func expandRange(range: (start: CGFloat,end: CGFloat),
    ByAmount amount: CGFloat) -> (start: CGFloat,end: CGFloat) {
      
      var resultingRange = range
      if range.start > range.end {
        resultingRange.start += amount
        resultingRange.end   -= amount
      } else {
        resultingRange.start -= amount
        resultingRange.end   += amount
      }
      return resultingRange
  }

}