

import UIKit




// MARK: - Various enums and structs used throughout the InfiniteImageWheel Class
extension InfiniteImageWheel {
  
  final class Wedge: NSObject {
    
    // MARK: Prperties
    let imageName:    String
    var view:         WedgeImageView?
    var superview:    UIView?
    var constraints: [(superview: UIView, constraint: NSLayoutConstraint)] = []
    
    var width =   Angle(degrees: 90) {
      didSet {
        view?.angleWidth = width
      }
    }
    
    // MARK: Initialization
    init(            imageName: String,
                andWidth width: Angle,
        andSuperview superview: UIView) {
        
        self.imageName = imageName
        self.width     = width
        self.superview = superview
    }
    
    init(imageName: String) {
      self.imageName = imageName
    }
    
    // MARK: Convience Computed Properties
    var viewExists: Bool       { return hasValue(view)         }
    var viewDoesNotExist: Bool { return doesNotHaveValue(view) }
    
    var image: UIImage       {
      let image = UIImage(named: imageName)
      assert(hasValue(image), "Could Not Find Image \(imageName).")
      return image!
    }
    
    
    // MARK: Convience Helpers
    var layoutAngle: Angle? {
      set(angle) {
        if let angle = angle {
          transform(angle)
        }
      }
      get {
        if let transform = view?.transform {
          return Angle(transform: transform)
        } else {
          return nil
        }
      }
    }
    
    
    func transform(transform: CGAffineTransform) {
      view?.transform = transform
      show()
    }
    
    func transform(angle: Angle) {
      transform(CGAffineTransformMakeRotation(CGFloat(angle)))
    }
    
    func hide() {
      if let view = view {
        if view.alpha != 0.0   { view.alpha = 0.0 }
        let hiddenAngle = CGFloat(Angle(degrees: 180))
        view.transform = CGAffineTransformMakeRotation(hiddenAngle)
      }
    }
    
    func show() {
      if let view = view {
        if view.alpha != 1.0   { view.alpha = 1.0 }
      }
    }
    
    func createWedgeImageViewWithSuperview(superview: UIView) {
      self.superview = superview
      createWedgeImageView()
    }
    
    
    // MARK: Creation and Removal
    func createWedgeImageView() {
      if viewDoesNotExist {
        if let superview = superview {
          let image = self.image
          let aspect = imageAspect(image)
          
          if let view = view {
            assertionFailure("view already exists")
          } else {
            let wedgeImageView = WedgeImageView(image: image)
            wedgeImageView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.65)
            wedgeImageView.angleWidth = width
            wedgeImageView.opaque = false
            wedgeImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
            superview.addSubview(wedgeImageView)

            constraints += createCenterContraintsForView( wedgeImageView,
                                             toSuperview: superview)
            constraints += createHeightAndAspectContraintsForView( wedgeImageView,
                                                      toSuperview: superview,
                                                       withAspect: aspect)
            
            for (view,constraint) in constraints {
              view.addConstraint(constraint)
            }
            view = wedgeImageView
          }
        }
      }
    }
    
    func removeWedgeImageView() {
      for (view,constraint) in constraints {
        view.removeConstraint(constraint)
      }
      constraints.removeAll()
      view?.removeFromSuperview()
      view = nil
    }
    
    
    // MARK: Constraints
    func imageAspect(image: UIImage) -> CGFloat {
      return image.size.width / image.size.height
    }
    
    func createCenterContraintsForView(imageView: UIView,
      toSuperview superview: UIView)
      -> [(superview: UIView, constraint: NSLayoutConstraint)] {
        
        var constraints: [(superview: UIView, constraint: NSLayoutConstraint)] = []
        let centerY = NSLayoutConstraint(item: imageView,
                                    attribute: NSLayoutAttribute.CenterY,
                                    relatedBy: NSLayoutRelation.Equal,
                                       toItem: superview,
                                    attribute: NSLayoutAttribute.CenterY,
                                   multiplier: 1.0,
                                     constant: 0.0)
        superview.addConstraint(centerY)
        constraints.append((superview: superview, constraint: centerY))
        
        let centerX = NSLayoutConstraint(item: imageView,
                                    attribute: NSLayoutAttribute.CenterX,
                                    relatedBy: NSLayoutRelation.Equal,
                                       toItem: superview,
                                    attribute: NSLayoutAttribute.CenterX,
                                   multiplier: 1.0,
                                     constant: 0.0)
        superview.addConstraint(centerX)
        constraints.append((superview: superview, constraint: centerX))
        return constraints
    }
    
    func createHeightAndAspectContraintsForView(imageView: UIView,
      toSuperview superview: UIView,
      withAspect aspect: CGFloat)
                      -> [(superview: UIView, constraint: NSLayoutConstraint)] {
        
        var constraints: [(superview: UIView, constraint: NSLayoutConstraint)] = []
        let height = NSLayoutConstraint(item: imageView,
                                   attribute: NSLayoutAttribute.Height,
                                   relatedBy: NSLayoutRelation.Equal,
                                      toItem: superview,
                                   attribute: NSLayoutAttribute.Height,
                                  multiplier: 0.75,
                                    constant: 0.0)
        superview.addConstraint(height)
        constraints.append((superview: superview, constraint: height))
        
        let aspect = NSLayoutConstraint(item: imageView,
                                   attribute: NSLayoutAttribute.Width,
                                   relatedBy: NSLayoutRelation.Equal,
                                      toItem: imageView,
                                   attribute: NSLayoutAttribute.Height,
                                  multiplier: aspect,
                                    constant: 0.0)
        superview.addConstraint(aspect)
        constraints.append((superview: imageView, constraint: aspect))
        return constraints
    }

    
  }
}
