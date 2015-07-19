
import UIKit

extension CGSize {
  var sizeForMovie: CGSize {
    var height = self.height
    var width  = self.width
    
    if height.isNotMultipleOf4 {
      height = ceil(height / 4) * 4
    }
    
    if width.isNotMultipleOf4 {
      width = ceil(width / 4) * 4
    }
    
    return CGSize(width: width, height: height)
  }
  
  var isMovieSize: Bool {
    if self.height.isMultipleOf4 &&
       self.width.isMultipleOf4    {
      return true
    } else {
      return false
    }
  }
  
  var isNotMovieSize: Bool {
    return !isMovieSize
  }

}