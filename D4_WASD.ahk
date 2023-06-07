; ====================================================================
; ============================= READ ME ==============================
; ====================================================================
/*
TITLE:
	DIABLO IV: WASD controls
;	
AUTHOR:
	Tomasz 'highwind' Lewandowski
;
SUMMARY:
	The script allows for player's character control in Diablo IV using popular 'WASD' control scheme.
;	
DESCRIPTION:
	- The character's control is achieved through the script, by binding press/release events
		of 'WASD' buttons with mouse clicks occuring at certain screen locations.
	- Desired movement direction is determined by reading the combination of pressed buttons,
		and translating it into 4 cardinal directions and their diagonals.
	- Each direction has a point associated with it. These points are located in the corners
		and in the middle of the edges of the rectangular area offset from the edges of the screen.
	- At the end of each press/release event, a LMB click instruction is being sent at one of
		target points (cursor movement is not required) causing character to advance in that direction.
	- When the buttons are being held, the script starts a timer that renew movement clicks
		at predetermined interval. 
	- After releasing all directional buttons, LMB click message is sent at the center
		of the screen to stop the player's avatar.
	- All programmed time intervals and click locations are randomized within specified range,
		resulting in more realistic character behavior. 
;
CAVEAT:
	1) Player's character is not located exactly at the center of the screen. It may be necessary
		to tinker with the value of 'x/yCenterTweak' variables, which is translating center
		of the screen coordinate (positive values translate it right/down, negative values translate
		it left/up). See 'CONFIG' section below.
	2) The game changes the level of camera zoom depending on various circumstances. It may be
		different while exploring, while in town, in buildings, and possibly when fighting world
		bosses. Different zoom levels will influence player's position relative to the center
		of the screen, and may therefore cause 'WASD' movement to become skewed.
	3) After script detects the game window, you will hear a beep within 3 seconds. The script
		becomes active in game after the beep.
	4) Since the script triggers movement by left mouse clicks, it is important to configure
		the game appropriately, allowing proper synergy between the programs:
		A) OPTIONS -> CONTROLS -> GAMEPLAY section: turn off 'Combine Move/Interact/Basic Skill Slot'.
		B) Do not bind any skills with left mouse button (otherwise movement instructions will
			trigger skills if accidentaly aimed at monsters).
		C) Bind 'Move' to left mouse button.
		D) Unbind anything from W/A/S/D keys.
	5) You still control the aim of your skills and the direction of evade with your mouse cursor.
	6) Changing game resolution will cause script to loose screen calibration.
		Reload the script to recalibrate it.
	7) Use 'End' key to pause/resume the script. This will be helpful for using ingame chat
		without triggering movement. Pausing and resuming the script will trigger quick beep
		sound to indicate the change of status. 
	8) Script is still in early stage of development and may have bugs causing it to send unwanted
		movement clicks. For that reason, a failsafe keybind has been set. Pressing tilde/grave key (~/`)
		should stop any active movement command and will trigger quick click sound to notify the user
		that it has been triggered. You can rebind this hotkey by changing 'emergencyStopKey' variable.
		However the knowledge of AHK scripting language may be needed to define proper shortcut.
		Should work fine for function keys ("F1"-"F12") or simple letter keys("h", "n", etc.).
	9) To maintain continuous movement right after evasion, script sends several consequtive movement
		clicks in quick succession. You can tweak this behavior by modifying 'postEvade' variables.
;	
CAUTION:
	The legality of the script usage in game is debatable. According to Blizzard's EULA, paragraph 1Cii4:
	"any code and/or software, not expressly authorized by Blizzard, that can be used in connection with the Platform
	and/or any component or feature thereof which changes and/or facilitates the gameplay or other functionality;"
	... may be susceptible to suspension or revoking your license to use their Platform.
;	
	Inquiring Blizzard Support regarding script's EULA compliance resulted in a kind and professional,
	yet evasive, inconclusive reply. For those reasons, please do note that this script is proof of concept only
	and should not be used in game.
;
INSTALLATION:
	1) Go to https://www.autohotkey.com/ and download the software. The script has been written for version 1.1.
	2) Download the script in .ahk format or copy its contents into .txt file and change the extension manually to .ahk.
	3) Right click script file and chose 'Run Script'. Its icon should show up in the system tray.
	4) Right clicking the tray icon allows to restart, pause or exit the script.
;	
KNOWN ISSUES:
	1) On rare occasion, when triggering skill at the same time when movement clicked occurs, the skill may be aimed at the direction of movement, not towards mouse cursor.
*/
; ====================================================================
; =========================== READ ME END ============================
; ====================================================================
;
;
#NoEnv
#Persistent
#MaxHotkeysPerInterval, 500
;
SendMode Input
SetWinDelay -1
SetBatchLines -1
SetTitleMatchMode, 3
CoordMode, Mouse, Screen
CoordMode, ToolTip, Screen 
;
;
; ====================================================================
; ============================== CONFIG ==============================
; ====================================================================
appName := "Diablo IV"			        ; needs to match game window title exactly
;
; keys below can be rebinded (check https://www.autohotkey.com/docs/v1/KeyList.htm for more info)
emergencyStopKey := "``"			      ; press this to force stop character if movement bugs out; `` is default for tylda key buc can be rebinded
evadeKey := "RButton"			          ; key bind matching in game evade hotkey
;
xCenterTweak := 0				            ; translates the coordinate (in pixels) of the center of the screen horizontally (- left / + right), modify to tweak the skew of vertical movement direction
yCenterTweak := -36				          ; translates the coordinate (in pixels) of the center of the screen vertically (- up / + down), modify to tweak the skew of horizontal movement direction
xOffset := 300					            ; offset value (in pixels) from left/right edge of the screen where the click to move character occurs, modify to tweak diagonal movement direction
yOffset := 200					            ; offset value (in pixels) from top/bottom edge of the screen where mouse click to move character occurs, modify to tweak diagonal movement direction
xStopOffset := 45				            ; amount of pixels from the tweaked center of the screen (horizontally), where the click to stop the character occurs
yStopOffset := 35				            ; amount of pixels from the tweaked center of the screen (vertically), where the click to stop the character occurs
;
sustainedMovementPeriod := 400	    ; average time (in milliseconds) between consecutive clicks while moving continuously in the same direction
sustainedMovementDeviation := 200 	; maximum time deviation (+/- from average) between consecutive movement clicks while in sustained movement
;
moveCoordDeviation := 50			      ; maximum distance (in pixels) from the perfect coordinate at which click to move the character may occur
stopCoordDeviation := 12			      ; maximum distance (in pixels) from the perfect coordinate at which click to stop the character may occur
;
; if too big, values below may result in perceived lagginess of movement or lost inputs:
postClickAvgDelay := 20			        ; the average length of pause (in milliseconds) after each click sent by the script; makes it less spammy, but also less responsive
postClickDelayDeviation := 15		    ; the amount of time that the pause may deviate from the average to simulate more realistic behavior
;
postEvadeClicks := 6			          ; number of movement clicks occurring right after evade was triggered
postEvadeClickPeriod := 20		      ; average time (in milliseconds) between consecutive clicks after evasion
postEvadeClickDeviation := 10		    ; maximum time deviation (+/- from average) between consecutive clicks after evasion
; ====================================================================
; ============================ CONFIG END ============================
; ====================================================================
;
;
;
; ====================================================================
; ========================== INITIALIZATION ==========================
; ====================================================================
fullCombo := ""
prevDirCombo := ""
currDirCombo := ""
scriptPause := false
tmrMove := New MovementTimer()
;
WinWaitActive, %appName%
Sleep 3000
SoundBeep
;
SetupCoordinates()
; ====================================================================
; ======================== INITIALIZATION END ========================
; ====================================================================
;
;
;
; ====================================================================
; ============================== SCRIPT ==============================
; ====================================================================
#If WinActive(appName)
;
Hotkey, %emergencyStopKey%, EmergencyStop
Hotkey, %evadeKey%, Evade
;
;
w::
a:: 
s::
d::
Critical 
if (scriptPause)
{
	Send, %A_ThisHotkey%
	return
}
if (InStr(fullCombo, A_ThisHotkey))
	return
fullCombo := fullCombo A_ThisHotkey
if (StrLen(fullCombo) == 1)
{
	diagonalAwaitMS := 50
	startTime := A_TickCount
	Loop
	{
		diagonalKey := isAnyDirPressedFromStr(StrReplace("wasd", A_ThisHotkey, ""))
		if (diagonalKey != "")
		{
			fullCombo := fullCombo diagonalKey
			Break
		}
		elapsedTime := A_TickCount - startTime
		if (elapsedTime > diagonalAwaitMS)
			Break
	}
}
dirCombo := SubStr(fullCombo, StrLen(fullCombo) - 1)
tmrMove.Start(dirCombo)
return
;
;
w up::
a up::
s up::
d up::
Critical
if (scriptPause)
{
	return
}
strButton := StrReplace(A_ThisHotkey, " up", "")
fullCombo := StrReplace(fullCombo, strButton, "") 
if (fullCombo == "")
{
	tmrMove.Stop()
	if (A_TimeSincePriorHotkey < 100 and InStr(A_PriorHotkey,"up"))
	{
		prevCombo := StrReplace(A_PriorHotkey, " up", "") strButton
	}
	else
	{
		prevCombo := strButton
	}
	
	postMovementDelay := randomize(postClickAvgDelay, postClickDelayDeviation)
	Move(prevCombo, true, postMovementDelay)
}
else
{
	if (StrLen(fullCombo) == 1)
	{
		diagonalAwaitMS := 50
		startTime := A_TickCount
		Loop
		{
			if (!GetKeyState(fullCombo,"P"))
			{
				return
			}
			
			elapsedTime := A_TickCount - startTime
			if (elapsedTime > diagonalAwaitMS)
				Break
		}
	}
	dirCombo := SubStr(fullCombo, StrLen(fullCombo) - 1)
	tmrMove.Start(dirCombo)
}
return
;
;
~End::
Critical
if (scriptPause)
{
	SoundBeep, 5000, 10
}
else
{
	SoundBeep, 1000, 10	
	tmrMove.Stop()
	isKiting := false
	ControlClick, x%xCenter% y%yCenter%, A,, L, 1, NA
}
scriptPause := !scriptPause
return
;
;
Evade:
Critical
if (tmrMove.isRunning)
	tmrMove.Stop()
Send {%A_ThisHotkey%}
tmrMove.ResumeEvade(postEvadeClickPeriod, postEvadeClicks)
return
;
;
EmergencyStop:
fullCombo := ""
tmrMove.Stop()
isKiting := false
ControlClick, x%xCenter% y%yCenter%, A,, L, 1, NA
SoundBeep, 5000, 10
return
; ====================================================================
; ============================ SCRIPT END ============================
; ====================================================================
;
;
;
; ====================================================================
; ============================ FUNCTIONS =============================
; ====================================================================
Move(dirCombination, isStopping := false, postMovementDelay := 0)
{
	global
	
	if (!isStopping and isAnyDirPressed() == "")
		return
	
	if isKiting
	{
		Send, {%kiteKey%}
		sleep 50
	}
	
	Switch dirCombination
	{
		case "w", "sw":
		Dir := N
		
		case "a", "da":
		Dir := W
		
		case "s", "ws":
		Dir := S
		
		case "d", "ad":
		Dir := E
		
		case "wa", "aw":
		Dir := NW
		
		case "as", "sa":
		Dir := SW
		
		case "sd", "ds":
		Dir := SE
		
		case "dw", "wd":
		Dir := NE
	}
	
	Coord := (isStopping) ? {x: Dir.xStop, y: Dir.yStop} : {x: Dir.xMove, y: Dir.yMove}
	
	Coord := (isStopping) ? randomizeCoord(Coord, stopCoordDeviation) : randomizeCoord(Coord, moveCoordDeviation)
	CallClick(Coord)
	
	if (postMovementDelay == 0)
		return
	
	Sleep, %postMovementDelay%
}
;
;
CallClick(coord)
{
	Global
	If !WinActive(appName)
		return

	xCoord := coord.x
	yCoord := coord.y
	
	ControlClick, x%xCoord% y%yCoord%, A,, L, 1, NA
}
;
;
randomize(average, deviation)
{
	Loop
	{
		Random, x, -1.0, 1.0
		Random, y, -1.0, 1.0
		r := x * x + y * y
		if r <= 1
			Break
	}
	rndDev := x * deviation
	return Round(average + rndDev)
}
;
;
isAnyDirPressed()
{
	return isAnyDirPressedFromStr("wasd")
}
;
;
isAnyDirPressedFromStr(comboStr)
{
	Loop, Parse, comboStr
	{
		if (GetKeyState(A_LoopField, "P"))
			return A_LoopField
	}
	return ""
}
;
;
randomizeCoord(inCoord, deviation)
{
	Global
	
	x := inCoord.x
	y := inCoord.y
	
	xDev := randomize(x, deviation)
	yDev := randomize(y, deviation)
	
	if (xDev < xLeft)
	{
		xDev := xLeft + (xLeft - xDev)
	}
	else if (xDev > xRight)
	{
		xDev := xRight + (xRight - xDev)
	}
	
	if (yDev < yTop)
	{
		yDev := yTop + (yTop - yDev)
	}
	else if (yDev1 > yBottom)
	{
		yDev := yBottom + (yBottom - yDev)
	}

	return {x: xDev, y: yDev}
}
;
;
SetupCoordinates()
{
	Global
	WinGetPos, xWin, yWin, wWin, hWin, A
	xCenter := xWin + wWin / 2 + xCenterTweak
	yCenter := yWin + hWin / 2 + yCenterTweak
	
	xLeft := xWin + xOffset
	xMid := xWin + wWin / 2
	xRight := xWin + wWin - xOffset
	
	yTop := yWin + yOffset
	yMid := yWin + hWin / 2
	yBottom := yWin + hWin - yOffset
	
	NW := {xMove: xLeft, yMove: yTop, xStop: xCenter - xStopOffset, yStop: yCenter - yStopOffset}
	N := {xMove: xMid, yMove: yTop, xStop: xCenter, yStop: yCenter - yStopOffset}
	NE := {xMove: xRight, yMove: yTop, xStop: xCenter + xStopOffset, yStop: yCenter - yStopOffset}
	W := {xMove: xLeft, yMove: yMid, xStop: xCenter - xStopOffset, yStop: yCenter}
	E := {xMove: xRight, yMove: yMid, xStop: xCenter + xStopOffset, yStop: yCenter}
	SW := {xMove: xLeft, yMove: yBottom, xStop: xCenter - xStopOffset, yStop: yCenter + yStopOffset}
	S := {xMove: xMid, yMove: yBottom, xStop: xCenter, yStop: yCenter + yStopOffset}
	SE := {xMove: xRight, yMove: yBottom, xStop: xCenter + xStopOffset, yStop: yCenter + yStopOffset}
	return
}
;
;
class MovementTimer {
	__New() {
		this.isRunning := false
		this.timeToNextMove := 0
		this.lastTickTime := 0
		this.postEvadeDelay := 0
		this.postEvadeCounter := 0
		this.postEvadeDeviation := 0
		this.dir := ""
	}
	
	Call() {
		Global
		if (!WinActive(appName))
		{
			SetTimer, % this, Off
			return
		}
		
		if (isAnyDirPressed() == "")
		{
			this.Stop()
			return
		}
		
		if (this.postEvadeCounter > 0 then)
		{
			this.postEvadeCounter := this.postEvadeCounter - 1
			this.timeToNextMove := randomize(this.postEvadeDelay, this.postEvadeDeviation)
		}
		else
		{
			this.postEvadeDelay := 0
			this.postEvadeCounter := 0
			this.postEvadeDeviation := 0
			this.timeToNextMove := randomize(sustainedMovementPeriod, sustainedMovementDeviation)
		}
		
		postMovementDelay := randomize(postClickAvgDelay, postClickDelayDeviation)
		
		Move(this.dir, false, postMovementDelay)
		this.lastTickTime := A_TickCount
		SetTimer, % this, % this.timeToNextMove
	}
	
	Start(dir){
		Global
		this.dir := dir
		this.isRunning := true
		this.Call()
	}
	
	Stop() {
		SetTimer % this, Off
		this.isRunning := false
		this.timeToNextMove := 0
		this.postEvadeCounter := 0
	}
	
	ResumeEvade(delay := 0, counter := 1, deviation := 0) {
		this.isRunning := true
		this.postEvadeDelay := delay
		this.postEvadeCounter := counter
		this.postEvadeDeviation := deviation
		this.timeToNextMove := delay
		SetTimer, % this, % this.timeToNextMove
	}
	
	TimeSinceLast() {
		return (A_TickCount - this.lastTickTime)
	}
}
;
;
;	LICENSING (https://opensource.org/license/bsd-3-clause/):
;
;	Copyright (c) 2023, highwind
;
;	Redistribution and use in source and binary forms, with or without modification, are permitted
;	provided that the following conditions are met:
;
;	1. Redistributions of source code must retain the above copyright notice, this list of conditions
;	and the following disclaimer.
;	2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions
;	and the following disclaimer in the documentation and/or other materials provided with the distribution.
;	3. Neither the name of the copyright holder nor the names of its contributors may be used to
;	endorse or promote products derived from this software without specific prior written permission.
;
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
