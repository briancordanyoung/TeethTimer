    func animateToEachStep(var steps: [ImageWheelRotationKey]) {

        // If there are no steps, then be done.
        // (and avoid the crashes that will come later 
        //  from the assumption we have steps to do)
        if steps.count == 0 { return }
        // TODO: change 2 to be greater when closer to iamges.count
        let duration = animateWedgeDuration * CFTimeInterval(steps.count) / 2
        
        let lastStep = steps.last!
        // Remove the last step, because this final step will be animated
        // in the completion block.
        steps.removeLast()
        
        
        var startTime = CFTimeInterval(0)
        var stepDuration = CFTimeInterval(0)
        for step in steps {
            let wedge = self.wedgeForImage(step.image)
            stepDuration = CFTimeInterval(step.timePercent * CGFloat(animateWedgeDuration))
            
            let imageStep = BasicAnimation(duration: CGFloat(stepDuration))
            imageStep.property = AnimatableProperty(name: kPOPLayerRotation)
            imageStep.toValue = wedge.midRadian
            imageStep.beginTime = startTime
            imageStep.name = "Image-\(step.image)"
            imageStep.delegate = self
            Animation.addAnimation(imageStep, key: imageStep.property.name, obj: self.container.layer)
            
            
            startTime = startTime + stepDuration
        }
    
        let wedge = wedgeForImage(lastStep.image)

        let lastImage = SpringAnimation(tension: 1000, friction: 30, mass: 1)
        lastImage.property = AnimatableProperty(name: kPOPLayerRotation)
        lastImage.toValue = wedge.midRadian
        lastImage.name = "LastRotation"
        lastImage.beginTime = startTime
        lastImage.delegate = self
//        lastImage.completionBlock = { anim, finsihed in
//            self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
//        }
        Animation.addAnimation(lastImage, key: lastImage.property.name, obj: self.container.layer)
    }
