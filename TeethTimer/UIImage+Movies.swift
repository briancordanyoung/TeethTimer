import UIKit

extension UIImage {
  
  var imageScaledToMovieSize: UIImage {
    // If self is already the correct size for writing to a movie
    // return a copy of self.
    if self.size.isMovieSize {
      return self.copy() as! UIImage
    }
    
    // This UIImage need to be scaled to the correct dimentions for
    // writing to a movie
    let naturalSize = self.size
    let movieSize   = naturalSize.sizeForMovie
    
    let hasAlpha = false
    let scale: CGFloat = 2.0 // Automatically use scale factor of main screen
    
    UIGraphicsBeginImageContextWithOptions(movieSize, !hasAlpha, scale)
    self.drawInRect(CGRect(origin: CGPointZero, size: movieSize))
    
    let movieImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return movieImage
  }
  
}