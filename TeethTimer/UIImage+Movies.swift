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
    let movieSize = self.size.sizeForMovie
    let scale     = self.scale
    let hasAlpha  = false
    
    UIGraphicsBeginImageContextWithOptions(movieSize, !hasAlpha, scale)
    self.drawInRect(CGRect(origin: CGPointZero, size: movieSize))
    
    let movieImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return movieImage
  }
  
}