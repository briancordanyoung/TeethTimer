import AVFoundation
import UIKit

typealias CompletionHandler = () -> ()

enum FrameState {
  case idle
  case rendered(UIImage)
  case writing
}

struct SaveState {
  var frameState: FrameState = .idle
  var currentFrame: Int = 0
  var totalFrames:  Int = 0
  var startingRotation: CGFloat = 0
  var endingRotation:   CGFloat = 0
  var currentRotation:  CGFloat {
    let anglePerFrame = self.anglePerFrame
    let acculmulatedAngle = anglePerFrame * CGFloat(currentFrame - 1)
    let currentRotation: CGFloat
    if startingRotation > endingRotation {
      currentRotation = startingRotation - acculmulatedAngle
    } else {
      currentRotation = startingRotation + acculmulatedAngle
    }
    return currentRotation
  }
  
  var anglePerFrame: CGFloat {
    let totalRotation = abs(startingRotation - endingRotation)
    return totalRotation / CGFloat(totalFrames)
  }
  
  var completionHandler: () -> () = {}
  var timer: NSTimer?
  
  var movieMaker: MovieMaker?
  
  let padFormater: NSNumberFormatter = {
    let numberFormater = NSNumberFormatter()
    numberFormater.minimumIntegerDigits  = 4
    numberFormater.maximumIntegerDigits  = 4
    numberFormater.minimumFractionDigits = 0
    numberFormater.maximumFractionDigits = 0
    numberFormater.positivePrefix = ""
    return numberFormater
    }()
  
  func pad(number: Int) -> String {
    var paddedNumber = "0000"
    if let numberString = padFormater.stringFromNumber(number) {
      paddedNumber = numberString
    }
    return paddedNumber
  }

  var isComplete: Bool {
    return currentFrame > totalFrames
  }
  
  var hasNotBegun: Bool {
    return totalFrames == 0
  }

}

class MovieMaker {

  var frameTime = CMTimeMake(1, 60)
  let videoSettings: [NSObject:AnyObject]
  let completionHandler: CompletionHandler
  
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
      let movieName   = "TeethTimer.mp4"
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
  
  
  init( settings: [NSObject : AnyObject], completetionHandler: CompletionHandler ) {
    videoSettings = settings
    self.completionHandler = completetionHandler
    
    let sideEffectsAreBadBufferAdapter = bufferAdapter
    
    assetWriter.startWriting()
    assetWriter.startSessionAtSourceTime(kCMTimeZero)
  }
  
  
  // MARK: Helper method could not be implimented in swift.  Use obj-c
  //       helper class BDYVideoHelper with the same named class method.
  func newPixelBufferFromCGImage(image: CGImageRef) -> CVPixelBufferRef! {
    let trueObject: NSNumber = true
    let options: [NSObject: AnyObject] =
                            [kCVPixelBufferCGImageCompatibilityKey:trueObject,
                     kCVPixelBufferCGBitmapContextCompatibilityKey:trueObject]
    
    var buffer: Unmanaged<CVPixelBuffer>? = nil
    let frameWidth  = self.videoSettings[AVVideoWidthKey]  as! CGFloat
    let frameHeight = self.videoSettings[AVVideoHeightKey] as! CGFloat
    
    
//    let status = CVPixelBufferCreate( kCFAllocatorDefault,
//                                      UInt(frameWidth),
//                                      UInt(frameHeight),
//                                      OSType(kCVPixelFormatType_32ARGB),
//                                      options,
//                                      &buffer)
    
//    CVPixelBufferLockBaseAddress(buffer, 0)
//    pxdata = CVPixelBufferGetBaseAddress(buffer)
//    
//    rgbColorSpace = CGColorSpaceCreateDeviceRGB()
//    context = CGBitmapContextCreate(pxdata,
//                                    frameWidth,
//                                    frameHeight,
//                                    8,
//                                    4 * frameWidth,
//                                    rgbColorSpace,
//                                    kCGImageAlphaNoneSkipFirst as! CGBitmapInfo)
//    
//    CGContextConcatCTM(context, CGAffineTransformIdentity)
//    CGContextDrawImage(context, CGRectMake(0,
//      0,
//      CGImageGetWidth(image),
//      CGImageGetHeight(image)),
//      image)
//    CGColorSpaceRelease(rgbColorSpace)
//    CGContextRelease(context)
//    CVPixelBufferUnlockBaseAddress(buffer, 0)
    
    return buffer?.takeUnretainedValue()
  }
}


extension TimerViewController {
  
  func setupViewsBeforeRendering() {
    startPauseButton.hidden = true
    resetButton.hidden      = true
    timerLabel.hidden       = true
    saveFrameButton.hidden  = true
  }
  
  func resetViewsAfterRendering() {
    self.startPauseButton.hidden     = false
    self.resetButton.hidden          = false
    self.timerLabel.hidden           = false
    self.saveFrameButton.hidden      = false
    self.saveState.completionHandler = {}
  }
  

  
  // Method used to start the process of rendering and saving the UI
  func saveFrames() {
    if saveState.hasNotBegun {
      if let gavinWheel = gavinWheel, imageWheelView = imageWheelView {
        setupViewsBeforeRendering()
        setupSaveStateWith(gavinWheel, AndImageWheel: imageWheelView)
      } else {
        // Can't find the views needed to render!
      }
    }
  }
  
  func setupSaveStateWith(wheelControl: WheelControl,
              AndImageWheel imageWheel: ImageWheel) {
    
    saveState.completionHandler = resetViewsAfterRendering

    let wedgeWidthAngle     = imageWheel.wedgeWidthAngle
    let halfWedgeWidthAngle = wedgeWidthAngle / 2
    let workingRange        = (start: wheelControl.maximumRotation!,
                                 end: wheelControl.minimumRotation!)
                
    // The complete range (in radians) from the furthers point in each direction
    // the wheelControl may rotate.  Including the half a wedge width past
    // the minimum and maximum rotation points when dampening completely stops
    // the rotation.
    let range = expandRange(workingRange, ByAmount: halfWedgeWidthAngle)
    let radiansInRange  = abs(range.start - range.end)
    let degreesInRange  = Circle().radian2Degree(radiansInRange)
    let framesPerDegree = CGFloat(2)
    
    saveState.startingRotation = range.start
    saveState.endingRotation   = range.end
    saveState.totalFrames      = Int(degreesInRange * framesPerDegree)
saveState.totalFrames      = 10 // TODO: Remove
    saveState.currentFrame     = 1
    
    wheelControl.rotationAngle = saveState.currentRotation
    
    saveState.timer = NSTimer.scheduledTimerWithTimeInterval( 0.1,
                                      target: self,
                                    selector: Selector("checkStateAndContinue"),
                                    userInfo: nil,
                                     repeats: true)
  }
  
  
  func checkStateAndContinue() {
    if saveState.isComplete {
      tearDownAndResetSaveState()
    } else {
      checkForNextStage()
    }
  }
  
  func checkForNextStage() {
    
    switch saveState.frameState {
      
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
    saveState.frameState = .rendered(image)
  }
  
  
  func setupMovieMaker() {
    let settings = BDYVideoHelper.videoSettingsWithCodec( AVVideoCodecH264,
                                            withWidth: self.view.frame.width,
                                            andHeight: self.view.frame.height)
    saveState.movieMaker = MovieMaker(settings: settings,
                           completetionHandler: saveState.completionHandler)
  }
  
  func writeFrameToMovie(image: UIImage) {
    
    
    if doesNotHaveValue(saveState.movieMaker) {
      setupMovieMaker()
    }
    
    let movieMaker = saveState.movieMaker

    
    if let movieMaker = movieMaker {
      let writerInput = movieMaker.writerInput
      
      if writerInput.readyForMoreMediaData {
        saveState.frameState = .writing
        let i = saveState.currentFrame - 1
        
        let sampleBuffer = BDYVideoHelper.newPixelBufferFromImage(image)
        
        if sampleBuffer != nil {
          let sampleBufferRef = sampleBuffer.takeUnretainedValue()
          
          let presentTime: CMTime
          if (i == 0) {
            presentTime  = kCMTimeZero
          }else{
            let lastTime = CMTimeMake(Int64(i), movieMaker.frameTime.timescale)
            presentTime  = CMTimeAdd(lastTime, movieMaker.frameTime)
          }
          movieMaker.bufferAdapter.appendPixelBuffer(sampleBufferRef,
                                              withPresentationTime: presentTime)
          
          // CFRelease(sampleBuffer) // Core Foundation objects are automatically
          //                         // automatically memory managed
          finishedWritingFrame()
        }
        
      }
    }
  }
  
  func writeFrame(image: UIImage) {
    // TODO: Save on background thread
    saveState.frameState = .writing
    
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
    saveState.currentFrame += 1
    gavinWheel?.rotationAngle = saveState.currentRotation
    saveState.frameState = .idle
  }
  
  func tearDownAndResetSaveState() {
    saveState.movieMaker?.assetWriter.finishWritingWithCompletionHandler() {
      println("Movie is ready.")
    }
    saveState.movieMaker?.writerInput.markAsFinished()
    saveState.timer?.invalidate()
    saveState.completionHandler()
    saveState = SaveState()
  }

  // Helpers
  func urlForFrame() -> NSURL? {
    var url: NSURL?
    
    let frameNumber = saveState.currentFrame
    
    let paths = NSFileManager.defaultManager()
      .URLsForDirectory( .DocumentDirectory, inDomains: .UserDomainMask)
    let path = paths.last as? NSURL
    
    if let path = path {
      if (frameNumber == 1) { println(path) }
      let frameString = saveState.pad(frameNumber)
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
