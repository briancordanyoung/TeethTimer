TODO:
---------------------------------------
- TimerViewController:
	- Implement percentage dictionary for length of time to display each image
- ImageWheel
	- Init() implement decoder and state restoration
- WheelControl:
	- how close to a full circle the difference can be compared to
	- Should undampenedNewRotation be feed in to directionsToDampenUsingAngle()?
	- try to replace CGAffineTransformRotate() with CGAffineTransformMakeRotation()
	- fix internalRotationOffset
	- Figure out spring animation for WheelControl

- Background playback
	- stop AVfoundation from overtaking background audio playback

- Features
	- Settings
		- Turn on Multiple Users
	- User ViewController
		- history
		- set user name
	- per user history, stored in iCloud
		- install Realm
	- Save to home screen seprate users
		- user url routing to set current user
		- how to save to home screen a different user

- Visual improvemets
	- layout
		- resize wheel to keep face near top of view
	- Button:
		- Start/Pause/Done button
		- Reset Button
	- Background
		- Add video and sinc to rotation
		
	-Graphics
		- Drop Shadow
		- Clean up images
		- Draw Icon
		
-refactor code
	New type: Cicle (radial?) Revolution
		replace all radian & degree code with circle type
	switch All movie Caching to the same extension "mp4"

Design:
---------------------------------------
[Visual Inspiration](https://vimeo.com/118801020)

Reference:
---------------------------------------
View Tree:

	- View (Timer View Controller)
		- snapshotView
			- controlView
				- WheelControl
					- backgroundView (self)
					- WheelView
						ImageWheel
							-imageView (Wedges)

Contraints:

	- View (Timer View Controller)
		- snapshotView
			- controlView
				- WheelControl
					- backgroundView (self)
					- WheelView
						ImageWheel
							-imageView (Wedges)
							
							
							










