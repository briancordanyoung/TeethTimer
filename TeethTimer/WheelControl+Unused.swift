import UIKit

// MARK: - Old methods I wanted to keep around and up-to-date while I refactor
//         These shouldn't be used any more.

extension WheelControl {

//  // MARK: Wheel State
//  func setRotationUsingAngle(angle: Angle) {
//    assert(false, "setRotationUsingAngle: should not be used")
//    
//      let newRotation = rotationUsingAngle( Rotation(angle), AndRotationState: rotationState)
//      setRotation(newRotation)
//  }
//
//  func rotationUsingAngle(angle: Rotation,
//       AndRotationState rotationState: RotationState) -> Rotation {
//
//      assert(false, "rotationUsingAngle:AndRotationState: should not be used")
//        
//      // This method is a hack!  This class is based on the idea that the
//      // accumulated rotation angle (in radians) can be known.
//      // At the time of this method, only the absolute angle from -3.14 to 3.14
//      // can be determined. Unless another API is pointed out, this method
//      // is used to make a best guess on tracking the accumulated rotations
//      // of the wheel as it passes over the dicontinuity of this absolute angle
//      // returned from the affine transform.
//
//      // In various conditions, this algorithm breaks down and can not
//      // determin the correct accumulated rotation.  It returns the last known
//      // good state in the hopes that the next evaluation can figure it out.
//
//      // Worce: execptionally fast rotations from the user or animation could
//      // create overly large jumps between evaluations may produce the wrong
//      // guess.
//
//      // During user interaction, this works. The angle difference from the
//      // initial touch is recalculated each time, so ONLY the final evaluation
//      // of this method, when touch ends, is used to keep the rotation in sync
//      // with the current absolute angle.
//
//      // During animations, it is best to use the expected end state of the
//      // animation to set the currentRotation property to the expected value,
//      // (or more precicly, the rotationState property holding backing struct)
//      // overriding the accumulated changes made throughout the animation
//
//      let rotationCountFromZero = Int(abs(angle / Rotation.full))
//      let tooManyTries          = rotationCountFromZero + 2
//
//      var rotation = angle
//
//      var difference = abs(rotationState.current - rotation)
//      var previousDifference = difference
//
//      // When rotating over the dicontinuity between the -3.14 and 3.14 angles,
//      // we need to figure out what to add/substract from rotation to keep
//      // incrementing the rotation in the correct direction
//      var addOrSubtract = true
//      var tries: [String] = []
//
//      // TODO: Test how close to a full circle the difference can be compared to.
//      //       the closer to 2 * M_PI we get, the less room for problems during
//      //       fast rotations.
//      while difference > Rotation.threeQuarter {
//        if difference >= previousDifference {
//          addOrSubtract = !addOrSubtract
//        }
//        if addOrSubtract {
//          rotation -= Rotation.full
//          tries.append("Rotation After Adding:      \(rotation) d:\(difference)")
//        } else {
//          rotation += Rotation.full
//          tries.append("Rotation After Subtracting: \(rotation) d:\(difference)")
//        }
//        previousDifference = difference
//        difference = abs(rotationState.current - rotation)
//
//        // The algorithm has gone all wrong.
//        // This is a safty to break out of the loop
//        // and continue on with the previously saved state
//        if tries.count > tooManyTries {
//          rotation = rotationState.current
//          //NSLog("Error: WheelControl could not calculate total rotation when passing over the discontinuity. Tried \(tries.count) times.")
//          //for try in tries {
//          //  NSLog(try)
//          //}
//          break // break out of the while loop
//        }
//      }
//      
//      return rotation
//    }
//  
}

