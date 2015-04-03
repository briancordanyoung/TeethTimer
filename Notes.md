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
	- create animating curved mask for each image
	- Button:
		- Start/Pause/Done button
		- Reset Button
	- Blur Effect to lowerThird
	- Background
		- bubbles filling up BG
		- dynamics as wheel rotates
		- disperce on reset
		
	- Drop Shadow
	- Clean up images
	- Draw Icon

Design:
---------------------------------------
[Visual Inspiration](https://vimeo.com/118801020)