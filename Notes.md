TODO:
---------------------------------------
- TimerViewController:
	- Implement percentage dictionary for length of time to display each image
	- updateWheelWithPercentageDone(percentageDone: CGFloat)
- ImageWheel
	- Init() implement decoder
- WheelControl:
	- TODO: how close to a full circle the difference can be compared to
	- TODO: Should undampenedNewRotation be feed in to directionsToDampenUsingAngle()?
	- TODO: try to replace CGAffineTransformRotate() with CGAffineTransformMakeRotation()
	- TODO: fix internalRotationOffset
	- TODO: Figure out spring animation for WheelControl

- Visual improvemets
	- create animating curved mask for each image
	- Create Start/Pause/Done button
	- Create Reset Button
	- Add Blur Effect
	- Create Background
	- Create Drop Shadow
	- Clean up images

Design:
---------------------------------------
[Visual Inspiration](https://vimeo.com/118801020)