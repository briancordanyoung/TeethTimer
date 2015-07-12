//
//  TestLayerView.swift
//  WedgeViewTest
//
//  Created by Brian Cordan Young on 4/7/15.
//  Copyright (c) 2015 Brian Young. All rights reserved.
//

import UIKit

class PieImageView: UIView {
  
  var image: UIImage? {
    didSet {
      pieSliceLayer.CGImage = self.image?.CGImage
    }
  }
  
  var width: Angle {
    get {
      return Angle(pieSliceLayer.angleWidth)
    }
    set(newWidth) {
      pieSliceLayer.angleWidth = CGFloat(newWidth.radians)
    }
  }
  
  
  override class func layerClass() -> AnyClass {
    return PieSliceLayer.self
  }
  
  var pieSliceLayer: PieSliceLayer {
    return self.layer as! PieSliceLayer
  }
  
}