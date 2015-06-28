//
//  Developement.swift
//  TeethTimer
//
//  Created by Brian Cordan Young on 3/24/15.
//  Copyright (c) 2015 Brian Young. All rights reserved.
//

import UIKit

class Developement: NSObject {
  
  lazy var padNumber: NSNumberFormatter = {
    let numberFormater = NSNumberFormatter()
    numberFormater.minimumIntegerDigits  = 2
    numberFormater.maximumIntegerDigits  = 2
    numberFormater.minimumFractionDigits = 3
    numberFormater.maximumFractionDigits = 3
    numberFormater.positivePrefix = " "
    return numberFormater
    }()
  
  func pad(number: CGFloat) -> String {
    var paddedNumber = " 1.000"
    if let numberString = padNumber.stringFromNumber(number) {
      paddedNumber = numberString
    }
    return paddedNumber
  }
  
//  let f = NSNumberFormatter()
//  let f2 = NSNumberFormatter()

//  f.minimumIntegerDigits  = 3
//  f.maximumIntegerDigits  = 3
//  f.minimumFractionDigits = 3
//  f.maximumFractionDigits = 3
//  f.positivePrefix = " "
//  f.negativePrefix = "-"
//  f.paddingCharacter = " "
//  f2.minimumIntegerDigits  = 2
//  f2.maximumIntegerDigits  = 2
//  f2.minimumFractionDigits = 0
//  f2.maximumFractionDigits = 0
//  f2.positivePrefix = ""
//  f2.negativePrefix = ""
//  f2.paddingCharacter = " "
//}
//
//func pad(number: Double) -> String {
//  return f.stringFromNumber(number)!
//}
//
//func pad(number: Rotation) -> String {
//  return pad(number.value)
//}
//
//func pad(number: Angle) -> String {
//  return pad(number.value)
//}
//
//func pad2(number: Double) -> String {
//  return f2.stringFromNumber(number)!
//}
//
//func p2(number: Int) -> String {
//  return pad2(Double(number))
//}
//
//func pad2(number: Rotation) -> String {
//  return pad2(number.value)
//}
//
//func pad2(number: Angle) -> String {
//  return pad2(number.value)
//}

  class func addTestImagesToView(view: UIView) {
    let wheelImageView     = UIImageView(image: UIImage(named: "WheelImage"))
    let wheelImageTypeView = UIImageView(image: UIImage(named: "WheelImageType"))
    
    wheelImageView.opaque = false
    wheelImageTypeView.opaque = false
    
    view.addSubview(wheelImageView)
    view.addSubview(wheelImageTypeView)
    
    
    wheelImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
    wheelImageTypeView.setTranslatesAutoresizingMaskIntoConstraints(false)
    
    view.addConstraint(NSLayoutConstraint( item: wheelImageView,
      attribute: NSLayoutAttribute.CenterY,
      relatedBy: NSLayoutRelation.Equal,
      toItem: view,
      attribute: NSLayoutAttribute.CenterY,
      multiplier: 1.0,
      constant: 0.0))
    
    view.addConstraint(NSLayoutConstraint( item: wheelImageView,
      attribute: NSLayoutAttribute.CenterX,
      relatedBy: NSLayoutRelation.Equal,
      toItem: view,
      attribute: NSLayoutAttribute.CenterX,
      multiplier: 1.0,
      constant: 0.0))
    
    wheelImageView.addConstraint( NSLayoutConstraint(item: wheelImageView,
      attribute: NSLayoutAttribute.Height,
      relatedBy: NSLayoutRelation.Equal,
      toItem: nil,
      attribute: NSLayoutAttribute.NotAnAttribute,
      multiplier: 1.0,
      constant: 600.0))
    
    wheelImageView.addConstraint( NSLayoutConstraint(item: wheelImageView,
      attribute: NSLayoutAttribute.Width,
      relatedBy: NSLayoutRelation.Equal,
      toItem: nil,
      attribute: NSLayoutAttribute.NotAnAttribute,
      multiplier: 1.0,
      constant: 600.0))
    
    view.addConstraint(NSLayoutConstraint( item: wheelImageTypeView,
      attribute: NSLayoutAttribute.CenterY,
      relatedBy: NSLayoutRelation.Equal,
      toItem: view,
      attribute: NSLayoutAttribute.CenterY,
      multiplier: 1.0,
      constant: 0.0))
    
    view.addConstraint(NSLayoutConstraint( item: wheelImageTypeView,
      attribute: NSLayoutAttribute.CenterX,
      relatedBy: NSLayoutRelation.Equal,
      toItem: view,
      attribute: NSLayoutAttribute.CenterX,
      multiplier: 1.0,
      constant: 0.0))
    
    wheelImageTypeView.addConstraint( NSLayoutConstraint(item: wheelImageTypeView,
      attribute: NSLayoutAttribute.Height,
      relatedBy: NSLayoutRelation.Equal,
      toItem: nil,
      attribute: NSLayoutAttribute.NotAnAttribute,
      multiplier: 1.0,
      constant: 400.0))
    
    wheelImageTypeView.addConstraint( NSLayoutConstraint(item: wheelImageTypeView,
      attribute: NSLayoutAttribute.Width,
      relatedBy: NSLayoutRelation.Equal,
      toItem: nil,
      attribute: NSLayoutAttribute.NotAnAttribute,
      multiplier: 1.0,
      constant: 400.0))
    
  }
  
}
