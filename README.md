# Diablo-IV-AHK-WASD
AutoHotKey script rebinding WASD keys into mouse clicks. Allows to control character in Diablo IV with WASD control scheme (similar to Diablo: Immortal).

TITLE:
	DIABLO IV: WASD controls, Proof of Concept
	
AUTHOR:
	Tomasz 'highwind' Lewandowski
	
SUMMARY:
	The script allows for player's character control in Diablo IV using popular 'WASD' control scheme.
	
DESCRIPTION:
	- The character's control is achieved through the script, by running a timer listening
		for 'WASD' input within predefined time interval.
	- Desired movement direction is determined by reading the combination of pressed buttons,
		and translating it into 4 cardinal directions and their diagonals.
	- Each direction has a point associated with it. These points are located in the corners
		and in the middle of the edges of the screen.
	- At the end of each timer interval, a LMB click instruction is being sent at one of target
		points (mouse movement is not needed) causing character to advance in that direction.
	- After releasing all directional buttons, LMB click message is sent at the center
		of the screen to stop the player's avatar.
	
CAVEAT:
	1) Player's character is not located exactly at the center of the screen. It may be necessary to tinker
		with the value of 'yCorrection' variable, which is translating center of the screen coordinate vertically
		(positive values translate it down, negative values translate it up). See 'CONFIG' section below.
	2) The game changes the level of camera zoom depending on various circumstances. It may be different
		while exploring, while in town, in buildings, and possibly when fighting world bosses. Different zoom levels
		will influence player's position relative to the center of the screen, and may therefore cause 'WASD' 
		movement to become skewed.
	3) After script detects the game window, you will hear a beep within 3 seconds. The script becomes actively
		listening after the beep.
	4) Since the script triggers movement by left mouse clicks, it is important to configure the game appropriately,
		allowing proper synergy between the programs:
		A) OPTIONS -> CONTROLS -> GAMEPLAY section: turn off 'Combine Move/Interact/Basic Skill Slot'.
		B) Do not bind any skills with left mouse button (otherwise movement instructions will trigger skills
			if accidentaly aimed at monsters).
		C) Bind 'Move' to left mouse button.
		D) Unbind anything from W/A/S/D keys.
	5) You still control the aim of your skills and the direction of evade with your mouse cursor.
	6) Changing game resolution will cause script to loose screen calibration. Reload the script to recalibrate it.
	7) Use 'End' key to pause/resume the script. This will be helpful for using ingame chat without triggering movement.
		Pausing and resuming the script will trigger quick beep sound to indicate the change of status. 
	8) You can test the script in Diablo III, by changing 'appName' variable. It won't work flawlessly though,
		as it is impossible to unbind LMB from basic attack or interaction command.
	9) To see the script in action (recorded during DIV beta): https://youtu.be/J-DrzL0N2p0
	
CAUTION:
	The legality of the script usage in game is debatable. According to Blizzard's EULA, paragraph 1Cii4:
	"any code and/or software, not expressly authorized by Blizzard, that can be used in connection with the Platform
	and/or any component or feature thereof which changes and/or facilitates the gameplay or other functionality;"
	... may be susceptible to suspension or revoking your license to use their Platform.
	
	Inquiring Blizzard Support regarding script's EULA compliance resulted in a kind and professional,
	yet evasive, inconclusive reply. For those reasons, please do note that this script is proof of concept only
	and should not be used in game.
	
	
INSTALLATION:
	1) Go to https://www.autohotkey.com/ and download the software. The script has been written for version 1.1.
	2) Download the script in .ahk format or copy its contents into .txt file and change the extension manually to .ahk.
	3) Right click script file and chose 'Run Script'. Its icon should show up in the system tray.
	4) Right clicking the tray icon allows to restart, pause or exit the script.
	
POTENTIAL FOR IMPROVEMENT:
	1) Additional randomization for repetitive actions. Randomized delays between clicks, randomized coordinates of
		click locations to 
	2) Smoother transitions between switched directions to give the movement more contoller-like appearance.
		For example by introducing 8 intermediate directions like N-NE or W-SW that script is triggering in
		quick succession for a short, transitory period of time when the direction of movement changes between main
		directions.
	3) Currently, holding a skill button stops the character. Modification to the script could be introduced, so that
		holding the button would stop the character only for the duration of typical key press (fraction of a second),
		after which the movement would be continued. As long as the button is held, this process would repeat itself.
