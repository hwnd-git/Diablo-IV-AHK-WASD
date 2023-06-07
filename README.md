# Diablo-IV-AHK-WASD
AutoHotKey script rebinding WASD keys into mouse clicks. Allows to control character in Diablo IV with WASD control scheme (similar to Diablo: Immortal).

### TITLE:
DIABLO IV: WASD controls
	
### AUTHOR:
Tomasz 'highwind' Lewandowski
	
### SUMMARY:
The script allows for player's character control in Diablo IV using popular 'WASD' control scheme.
	
### DESCRIPTION:
- The character's control is achieved through the script, by binding press/release events of 'WASD' buttons with mouse clicks occuring at certain screen locations.
- Desired movement direction is determined by reading the combination of pressed buttons, and translating it into 4 cardinal directions and their diagonals.
- Each direction has a point associated with it. These points are located in the corners and in the middle of the edges of the rectangular area offset from the edges of the screen.
- At the end of each press/release event, a LMB click instruction is being sent at one of target points (cursor movement is not required) causing character to advance in that direction.
- When the buttons are being held, the script starts a timer that renew movement clicks at predetermined interval. 
- After releasing all directional buttons, LMB click message is sent at the center of the screen to stop the player's avatar.
- All programmed time intervals and click locations are randomized within specified range, resulting in more realistic character behavior. 
	
### CAVEAT:
1) Player's character is not located exactly at the center of the screen. It may be necessary to tinker with the value of
  'x/yCenterTweak' variables, which is translating center of the screen coordinate (positive values translate it right/down,
  negative values translate it left/up). See 'CONFIG' section below.
2) The game changes the level of camera zoom depending on various circumstances. It may be different while exploring, while in town,
  in buildings, and possibly when fighting world bosses. Different zoom levels will influence player's position relative to the
  center of the screen, and may therefore cause 'WASD' movement to become skewed.
3) After script detects the game window, you will hear a beep within 3 seconds. The script becomes active in game after the beep.
4) Since the script triggers movement by left mouse clicks, it is important to configure the game appropriately,
  allowing proper synergy between the programs: <br/>
	a) OPTIONS -> CONTROLS -> GAMEPLAY section: turn off 'Combine Move/Interact/Basic Skill Slot'. <br/>
	b) Do not bind any skills with left mouse button (otherwise movement instructions will trigger skills
		if accidentaly aimed at monsters). <br/>
	c) Bind 'Move' to left mouse button. <br/>
	d) Unbind anything from W/A/S/D keys. <br/>
		
5) You still control the aim of your skills and the direction of evade with your mouse cursor.
6) Changing game resolution will cause script to loose screen calibration. Reload the script to recalibrate it.
7) Use 'End' key to pause/resume the script. This will be helpful for using ingame chat without triggering movement.
	Pausing and resuming the script will trigger quick beep sound to indicate the change of status. 
8) Script is still in early stage of development and may have bugs causing it to send unwanted movement clicks. For that reason,
  a failsafe keybind has been set. Pressing tilde/grave key (~/`) should stop any active movement command and will trigger quick
  click sound to notify the user that it has been triggered. You can rebind this hotkey by changing 'emergencyStopKey' variable.
  However the knowledge of AHK scripting language may be needed to define proper shortcut. Should work fine for function keys ("F1"-"F12")
  or simple letter keys("h", "n", etc.).
9) To maintain continuous movement right after evasion, script sends several consequtive movement clicks in
  quick succession. You can tweak this behavior by modifying 'postEvade' variables.
	
### CAUTION:
The legality of the script usage in game is debatable. According to Blizzard's EULA, paragraph 1Cii4:
> any code and/or software, not expressly authorized by Blizzard, that can be used in connection with the Platform
and/or any component or feature thereof which changes and/or facilitates the gameplay or other functionality;
(...) ay be susceptible to suspension or revoking your license to use their Platform.

Inquiring Blizzard Support regarding script's EULA compliance resulted in a kind and professional,
yet evasive, inconclusive reply. For those reasons, please do note that this script is proof of concept only
and should not be used in game.
	
	
### INSTALLATION:
1) Go to https://www.autohotkey.com/ and download the software. The script has been written for version 1.1.
2) Download the script in .ahk format or copy its contents into .txt file and change the extension manually to .ahk.
3) Right click script file and chose 'Run Script'. Its icon should show up in the system tray.
4) Right clicking the tray icon allows to restart, pause or exit the script.
	
### KNOWN ISSUES:
1) On rare occasion, when triggering skill at the same time when movement clicked occurs, the skill may be aimed at the
  direction of movement, not towards mouse cursor.
