; ====================================================================
; ============================= READ ME ==============================
; ====================================================================
/*
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
*/
; ====================================================================
; =========================== READ ME END ============================
; ====================================================================

#NoEnv			        		
#Persistent		       			
#MaxHotkeysPerInterval, 500    
SendMode Input		        
SetKeyDelay -1
SetControlDelay -1
SetTitleMatchMode, 3            

; ====================================================================
; ============================== CONFIG ==============================
; ====================================================================
appName := "Diablo IV"		; needs to match game window title exactly
yCorrection := -36			; moves the coordinate (in pixels) of the center of the screen vertically (- up / + down), allows tweaking the skew of horizontal movement direction
xOffset := 10000			; horizontal coordinate of mouse click when moving left or right (it is located outside the screen, but game interprets it as clicking on the edge)
yOffset := 10000			; vertical coordinate of mouse click when moving up or down (it is located outside the screen, but game interprets it as clicking on the edge)
xStopOffset := 40			; amount of pixels from the center of the screen (horizontally), where the click to stop the character occurs
yStopOffset := 30			; amount of pixels from the center of the screen (vertically), where the click to stop the character occurs
timerTickTime := 20			; time interval (in  milliseconds) between each scan of 'WASD' input
postClickDelay := 100		; the length of pause (in milliseconds) after each click sent by the script; makes it less spammy, but also less responsive
; ====================================================================
; =========================== CONFIG END =============================
; ====================================================================

wTickTime := 0
aTickTime := 0
sTickTime := 0
dTickTime := 0

WinWaitActive, %appName%   	
Sleep 3000
SoundBeep
WinGetPos, xWin, yWin, wWin, hWin, A
xCenter := xWin + wWin / 2
yCenter := yWin + hWin / 2 + yCorrection

SetTimer, WASDscanner, %timerTickTime%
scriptPause := false




#If WinActive(appName)

~End::
	if (scriptPause)
	{
		SoundBeep, 5000, 10	
		SetTimer, WASDscanner, %timerTickTime%
	}
	else
	{
		SoundBeep, 1000, 10
		ControlClick, x%xCenter% y%yCenter%, A,, L, 1, NA
		SetTimer, WASDscanner, Off
	}
	scriptPause := !scriptPause
return



~w up::
~a up::
~s up::
~d up::
	if scriptPause
		return
	if isPressedAny()
		return
	strButton := StrReplace(A_ThisHotkey, "~", "")
	strButton := StrReplace(strButton, " up", "")
	Coord := getStopCoord(strButton)
	xCoord := Coord.x
	yCoord := Coord.y
	ControlClick, x%xCoord% y%yCoord%, A,, L, 1, NA
	Sleep, %postClickDelay%
return



WASDscanner:
	if !WinActive(appName) 
		return
	if (scriptPause)
		return
	UpdateTickTimesWASD()
	if !isPressedAny()
		return
	if GetKeyState("1", "P") Or GetKeyState("2", "P") Or GetKeyState("3", "P") Or GetKeyState("4", "P")
		return

	xTarget := horizontalDirEval()
	yTarget := verticalDirEval()

	ControlClick, x%xTarget% y%yTarget%, A,, L, 1, NA
	Sleep, %postClickDelay%
return



getStopCoord(key)
{
	Global
	Switch key
	{
		case "w":
			Coord := {x: xCenter, y: yCenter - yStopOffset}
		case "a":
			Coord := {x: xCenter - xStopOffset, y: yCenter}
		case "s":
			Coord := {x: xCenter, y: yCenter + yStopOffset}
		case "d":
			Coord := {x: xCenter + xStopOffset, y: yCenter}
	}
	return Coord
}

UpdateTickTimesWASD()
{
	Global
	if isPressed("w"){
		if (wTickTime == 0)
			wTickTime := A_TickCount
	} 
	else 
	{
		wTickTime := 0
	}
	
	if isPressed("a"){
		if (aTickTime == 0)
			aTickTime := A_TickCount
	} 
	else 
	{
		aTickTime := 0
	}
	
	if isPressed("s"){
		if (sTickTime == 0)
			sTickTime := A_TickCount
	} 
	else 
	{
		sTickTime := 0
	}
	
	if isPressed("d"){
		if (dTickTime == 0)
			dTickTime := A_TickCount
	} 
	else 
	{
		dTickTime := 0
	}
}

horizontalDirEval()
{
	Global
	if !(isPressed("a") or isPressed("d"))
		return xCenter
	
	if (isPressed("a") and isPressed("d"))
	{
		return (aTickTime >= dTickTime) ? (xCenter - xOffset) : (xCenter + xOffset)
	}
	
	if isPressed("a")
		return xCenter - xOffset
	
	if isPressed("d")
		return xCenter + xOffset
}

verticalDirEval()
{
	Global
	if !(isPressed("w") or isPressed("s"))
		return yCenter
	
	if (isPressed("w") and isPressed("s"))
	{
		return (wTickTime >= sTickTime) ? (yCenter - yOffset) : (yCenter + yOffset)
	}
	
	if isPressed("w")
		return yCenter - yOffset
	
	if isPressed("s")
		return yCenter + yOffset
}

isPressed(key)
{
	return GetKeyState(key, "P")
}

isPressedAny()
{
	return (isPressed("w") or isPressed("a") or isPressed("s") or isPressed("d"))
}



;	LICENSING (https://opensource.org/license/bsd-3-clause/):

;	Copyright (c) 2023, Tomasz 'highwind' Lewandowski

;	Redistribution and use in source and binary forms, with or without modification, are permitted
;	provided that the following conditions are met:

;	1. Redistributions of source code must retain the above copyright notice, this list of conditions
;	and the following disclaimer.
;	2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions
;	and the following disclaimer in the documentation and/or other materials provided with the distribution.
;	3. Neither the name of the copyright holder nor the names of its contributors may be used to
;	endorse or promote products derived from this software without specific prior written permission.

;	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS”
;	AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
;	IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
;	ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
;	LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
;	DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
;	SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
;	CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR 
;	TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF 
;	THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.