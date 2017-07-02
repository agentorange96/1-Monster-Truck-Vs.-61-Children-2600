 rem 1 Monster Truck vs. 61 Children
 rem Copyright 2017 Peter Miller
 rem Load correct score sprites before compiling
 bank 1
 temp1 = temp1


 set tv ntsc
 set kernel DPC+
 set smartbranching on
 set optimization inlinerand
 set kernel_options collision(playfield,player1) 

 goto SETUP bank2

 rem set score color
 asm
minikernel
 ldx scoreBG
 stx COLUBK
 rts
end

 bank 2
 temp1 = temp1

SETUP
 drawscreen

 rem Define Constants
 const timeSeconds = 60
 const winPress1 = timeSeconds * 2
 const winPress2 = 2
 ;const noscore = 1
 const pfscore=1

 rem Define Variables
 dim buttonPressed = a
 dim frame = b
 dim secs = d
 dim stellaFix = e
 dim truckX = f
 dim truckY = g
 dim timerReset = h
 dim timerStop = i
 dim state = j
 dim presses1 = k
 dim presses2 = l
 dim moveState = m
 dim musicDur = n
 dim soundDur = r
 dim setupGraphics = o
 dim doReset = p
 dim scoreBG = q
 dim revEngine = s
 dim soundCount = t


 ;pfclear
 state = 0
 score = 000000
 secs = 60
 presses1 = 0
 presses2 = 0
 soundDur = 1
 goto MusicSetup


MAIN
 rem INSERT GAMEPLAY LOGIC
 gosub playMusic bank2
musicSkip
 gosub GraphicsSetup bank2
 gosub reset bank2
 gosub checkFire bank2
 if !state then goto gameSkip
 gosub playSounds bank2
 gosub timer bank2
 gosub judge bank2
 gosub moveTruck bank2
gameSkip
 gosub drawStatus bank2
 gosub draw bank2
 goto MAIN

 rem SUBROUTINES

 rem Keeps time
timer
 if timerReset = 1 then goto resetTimer
 goto keepTime
resetTimer
 timerStop = 0
 secs = 0
 frame = 0
 timerReset = 0
keepTime
 if timerStop = 1 then goto timerEnd
 frame = frame + 1
 if frame = 60 then frame = 0
 if frame = 0 then secs = secs + 1
 if secs = timeSeconds then timerStop = 1 : state = 2
timerEnd
 return

 rem Draws screen and elements
draw
 NUSIZ0 = $05
 player0x = truckX
 player0y = truckY
 _NUSIZ1 = $05
 player1x = player0x + 16
 player1y= player0y
 DF0FRACINC = 128
 DF1FRACINC = 128
 DF2FRACINC = 128
 DF3FRACINC = 128
 DF4FRACINC = 255
 DF6FRACINC = 255
 drawscreen
 return

 rem draws status bars
drawStatus
 if state = 0 then pfscore1 = %00000000 : pfscore 2 = %00000000 : goto endDrawStatus
 if secs = 60 then pfscore1 = %00000000 :  pfscorecolor = $40
 if secs < 60 then pfscore1 = %00000001 :  pfscorecolor = $40
 if secs < 52 then pfscore1 = %00000011 :  pfscorecolor = $16
 if secs < 45 then pfscore1 = %00000111 :  pfscorecolor = $16
 if secs < 37 then pfscore1 = %00001111 :  pfscorecolor = $16
 if secs < 30 then pfscore1 = %00011111 :  pfscorecolor = $C0
 if secs < 22 then pfscore1 = %00111111 :  pfscorecolor = $C0
 if secs < 15 then pfscore1 = %01111111 :  pfscorecolor = $C0
 if secs < 07 then pfscore1 = %11111111 :  pfscorecolor = $C0
 if presses2 > 1 then pfscore2 = %11111111
 if presses2 = 1 && presses1 < 120 then pfscore2 = %01111111
 if presses2 = 1 && presses1 < 90 then pfscore2 = %00111111
 if presses2 = 1 && presses1 < 60 then pfscore2 = %00011111
 if presses2 = 1 && presses1 < 30 then pfscore2 = %00001111
 if presses2 = 0 && presses1 < 120 then pfscore2 = %00000111
 if presses2 = 0 && presses1 < 90 then pfscore2 = %00000011
 if presses2 = 0 && presses1 < 60 then pfscore2 = %00000001
 if presses2 = 0 && presses1 < 30 then pfscore2 = %00000000
endDrawStatus
 return

 rem Resets the Game 
reset
 if !switchreset && !doReset then goto resetEnd
 timerReset = 1
 score = 123456
 presses1 = 0
 presses2 = 0
 state = 1
 setupGraphics = 0
 doReset = 0
resetEnd
 if !switchselect then goto selectEnd
 state = 0
 setupGraphics = 0
 score = 0
 presses1 = 0
 presses2 = 0
 secs = 60
selectEnd
 return

 rem Checks Fire Button
checkFire
 if joy0fire && buttonPressed = 1 then goto pressed
 goto notPressed
pressed
 if !state then doReset = 1 : goto fireEnd
 if timerStop = 0 then presses1 = presses1 + 1
 if presses1 = winPress1 then presses1 = 0 : presses2 = presses2 + 1
 buttonPressed = 0
 goto fireEnd
notPressed
 if !joy0fire && buttonPressed = 0 then buttonPressed = 1
fireEnd
 return

 rem Checks win/lose state
judge
 if state = 2 then goto jCont else goto jEnd
jCont
 if presses2 > winPress2 - 1 then goto jWin else goto jLose
jWin
 revEngine = 1
 score = 080808
 state = 3
 goto jEnd
jLose
 revEngine = 1
 score = 707070
 state = 4
 goto jEnd
jEnd
 return

 rem animates the truck
moveTruck
 if state = 3 then goto aWin
 if state = 4 then goto aLose
 if state = 1 then truckX = 0 : truckY = 150
 moveState = 0
 goto aEnd 
aWin
 if moveState = 0 then truckX = truckX+1 : truckY = truckY-1
 if moveState = 1 then truckX = truckX+1
 if moveState = 2 then truckX = truckX+1 : truckY = truckY+1
 if truckX = 42 && truckY = 108 then moveState = 1
 if truckX = 84 && truckY = 108 then moveState = 2
 if truckX = 126 && truckY = 150 then moveState = 3
 goto aEnd
aLose
 if moveState = 0 then truckX = truckX+1 : truckY = truckY-1
 if moveState = 1 then truckY = truckY+1
 if moveState = 2 then truckX = truckX+1
 if truckX = 42 && truckY = 108 then moveState = 1
 if truckX = 42 && truckY = 150 then moveState = 2
 if truckX = 126 && truckY = 150 then moveState = 3
 goto aEnd
aEnd
 return

 rem Play Music
playMusic
 musicDur = musicDur - 1
 if musicDur then goto skipMusic
 temp4 = sread(Music)
 if temp4 = 255 then goto MusicSetup
 temp5 = sread(Music)
 temp6 = sread(Music)
 AUDV1 = temp4
 AUDC1 = temp5
 AUDF1 = temp6
 musicDur = sread(Music)
 if switchrightb then AUDV1 = 0
skipMusic
 return

 rem Play Sound Effects
playSounds
 soundDur = soundDur - 1
 if soundDur then goto skipSound
 if revEngine then goto Rev else goto Idle
Rev
 temp4 = SoundRev[soundCount]
 if temp4 = 255 then revEngine = 0 : goto clearSound
 soundCount = soundCount + 1
 temp5 = SoundRev[soundCount] : soundCount = soundCount + 1
 temp6 = SoundRev[soundCount] : soundCount = soundCount + 1
 AUDV0 = temp4
 AUDC0 = temp5
 AUDF0 = temp6
 soundDur = SoundRev[soundCount] : soundCount = soundCount + 1
 goto skipSound
Idle
 temp4 = SoundIdle[soundCount]
 if temp4 = 255 then goto clearSound
 soundCount = soundCount + 1
 temp5 = SoundIdle[soundCount] : soundCount = soundCount + 1
 temp6 = SoundIdle[soundCount] : soundCount = soundCount + 1
 AUDV0 = temp4
 AUDC0 = temp5
 AUDF0 = temp6
 soundDur = SoundIdle[soundCount] : soundCount = soundCount + 1
 goto skipSound
clearSound
 soundCount = 0
 soundDur = 1
skipSound
 if switchleftb then AUDV0 = 0
 return

GraphicsSetup
 if setupGraphics then goto gEnd
 if state then goto gGame else goto gTitle
gGame
 scoreBG = $F0
 scorecolors:
 $0E
 $0E
 $0E
 $0E
 $0E
 $0E
 $0E
 $0E
end
 rem Define Sprites
 player0:
 %00000000
 %00000000
 %00000000
 %00000000
 %00000000
 %00000000
 %11111111
 %11111111
 %11111111
 %11100111
 %11000011
 %10011000
 %00111100
 %00100100
 %00100100
 %00100100
 %00111100
 %00011000
end
 player0color:
 $80
 $80
 $80
 $0E
 $40
 $40
 $40
 $0E
 $80
 $80
 $80
 $00
 $00
 $00
 $00
 $00
 $00
 $00
end
 player1:
 %11100000
 %10010000
 %10010000
 %10010000
 %10010000
 %10010000
 %11111111
 %11111111
 %11111111
 %11110011
 %11100001
 %00001101
 %00011110
 %00010010
 %00010010
 %00010010
 %00011110
 %00001100
end
 player1color:
 $80
 $80
 $80
 $0E
 $40
 $40
 $40
 $0E
 $80
 $80
 $80
 $00
 $00
 $00
 $00
 $00
 $00
 $00
end
 rem Define playfield
 playfield:
 ................................
 ................................
 ................................
 ................................
 ..X.X...........................
 ...X..XX...XXX....X.........XX..
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ......X.........................
 ......X.........................
 .....XX.........................
 .....XX.........................
 ....XXX....XXXXXXXXXX...........
 ....XXX....XXXXXXXXXX...........
 ...XXXX....XXXXXXXXXX...........
 ...XXXX....XXXXXXXXXX...........
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
end
 pfcolors:
   $0E
   $0E
   $0E
   $0E
   $0C
   $0C
   $0C
   $0A
   $0A
   $AA
   $AA
   $AC
   $AC
   $AC
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $40
   $FE
   $40
   $90
   $30
   $FE
   $40
   $90 ; Ground Level 
   $40
   $F0
   $F0
   $F0
   $F0
end
 rem Define background
 bkcolors:
   $0E
   $0E
   $0E
   $0E
   $0C
   $0C
   $0C
   $0A
   $0A
   $AA
   $AA
   $AC
   $AC
   $AC
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $AE
   $D8
   $D4
   $D4
   $F0
   $F0
end
 goto gEnd
gTitle
 scoreBG = $46
 rem Define Sprites
 player0:
 %00000000
end
 player0color:
 $00
end
 player1:
 %00
end
 player1color:
 $00
end
 rem Define playfield
 playfield:
 XXXXXXXXXXXXX...................
 XXXXXXXXXXXXX...................
 XXXXXXXXXXXXX...................
 X.X.X.X.X.X.X...................
 X.X.X.X.X.X.X...................
 XXXXXXXXXXXXX...................
 XXXXXXXXXXXXX...................
 XXXXXXXXXXXXX...................
 XX.X.X.X.X.XX...................
 XX.X.X.X.X.XX...................
 XXXXXXXXXXXXX...................
 XXXXXXXXXXXXX...................
 XXXXXXXXXXXXX...................
 X.X.X.X.X.X.X...................
 X.X.X.X.X.X.X...................
 XXXXXXXXXXXXX...................
 XXXXXXXXXXXXX..........XXXX.....
 XXXXXXXXXXXXX..........XXXXX....
 XX.X.X.X.X.XX..........X...X....
 XX.X.X.X.X.XX..........X...X....
 XXXXXXXXXXXXX..........X...X....
 XXXXXXXXXXXXX..........X...X....
 XXXXXXXXXXXXX..........XXXXXXXX.
 X.X.X.X.X.X.X..XXXXXXXXXXXXXXXX.
 X.X.X.X.X.X.X..XXXXXXXXXXXXXXXX.
 XXXXXXXXXXXXX..XXXXXXXXXXXXXXXX.
 XXXXXXXXXXXXX..XXXXXXXXXXXXXXXX.
 XXXXXXXXXXXXX..XXXXXXXXXXXXXXXX.
 XX.X.X.X.X.XX.XXXXXXXXXXXXXXXXXX
 XX.X.X.X.X.XX.XXXX..XXXXXXX..XXX
 XXXXXXXXXXXXX.XXX....XXXXX....XX
 XXXXXXXXXXXXX.X...XX.......XX...
 XXXXXXXXXXXXX....XXXX.....XXXX..
 X.X.X.X.X.X.X....X..X.....X..X..
 X.X.X.X.X.X.X....X..X.....X..X..
 XXXXXXXXXXXXX....X..X.....X..X..
 XXXXXXXXXXXXX....X..X.....X..X..
 XXXXXXXXXXXXX....X..X.....X..X..
 XX.X.X.X.X.XX....XXXX.....XXXX..
 XX.X.X.X.X.XX.....XX.......XX...
 XXXXXXXXXXXXX...................
 XXXXXXXXXXXXX...................
 XXXXXXXXXXXXX...................
 X.X.X.X.X.X.X...................
 X.X.X.X.X.X.X...................
 XXXXXXXXXXXXX...................
 XXXXXXXXXXXXX....XX..X...X.XXX..
 XXXXXXXXXXXXX...X..X.XX..X.X....
 XXXXXXXXXXXXX...X..X.X.X.X.X....
 ................X..X.X.X.X.XXX..
 ................X..X.X.X.X.X....
 ................X..X.X..XX.X....
 .................XX..X...X.XXX..
 ................................
 X...X..X..X...X..XX..XXX.XX.XXX.
 XX.XX.X.X.XX..X.X..X..X..X..X..X
 X.X.X.X.X.X.X.X.X.....X..X..X..X
 X.X.X.X.X.X.X.X..XX...X..XX.XXX.
 X...X.X.X.X.X.X....X..X..X..X..X
 X...X.X.X.X..XX.X..X..X..X..X..X
 X...X..X..X...X..XX...X..XX.X..X
 ................................
 ..XXXXX.XXXX..X...X..XXX..X..X..
 ....X...X...X.X...X.X...X.X..X..
 ....X...X...X.X...X.X.....X.X...
 ....X...XXXX..X...X.X.....XX....
 ....X...X...X.X...X.X.....X.X...
 ....X...X...X.X...X.X...X.X..X..
 ....X...X...X..XXX...XXX..X..X..
 ................................
 .....X...X..XXX.....XXX...X.....
 .....X...X.X...X...X...X.XX.....
 .....X...X.X.......X......X.....
 ......X.X...XXX....XXXX...X.....
 ......X.X......X...X...X..X.....
 ......X.X..X...X...X...X..X.....
 .......X....XXX.....XXX..XXX....
 ................................
 .XX..X.X.X.X..XXX..XXX..XX.X...X
 X..X.X.X.X.X..X..X.X..X.X..XX..X
 X....X.X.X.X..X..X.X..X.X..X.X.X
 X....XXX.X.X..X..X.XXX..XX.X.X.X
 X....X.X.X.X..X..X.X..X.X..X.X.X
 X..X.X.X.X.X..X..X.X..X.X..X..XX
 .XX..X.X.X.XX.XXX..X..X.XX.X...X
 ................................
 ................................
 ................................
 ................................
 ................................
end
 pfcolors:
   $80
   $80
   $80
   $82
   $82
   $82
   $84
   $84
   $84
   $86
   $86
   $86
   $84
   $84
   $84
   $82
   $82
   $82
   $80
   $80
   $80
   $82
   $82
   $82
   $84
   $84
   $84
   $86
   $86
   $86
   $84
   $84
   $84
   $80
   $80
   $80
   $82
   $82
   $82
   $84
   $84
   $84
   $86
   $86
   $86
   $84
   $84
   $84
   $82
   $82
   $82
   $80
   $80
   $80
   $82
   $82
   $82
   $84
   $84
   $84
   $86
   $86
   $86
   $84
   $84
   $84
   $82
   $82
   $82
   $84
   $84
   $84
   $86
   $86
   $86
   $84
   $84
   $84
   $82
   $82
   $82
   $84
   $84
   $84
   $86
   $86
   $86
   $84
end
 rem Define background
 bkcolors:
   $40
   $40
   $40
   $42
   $42
   $42
   $0C
   $0C
   $0C
   $0E
   $0E
   $0E
   $0C
   $44
   $44
   $42
   $42
   $42
   $40
   $40
   $08
   $0A
   $0A
   $0A
   $0C
   $0C
   $0C
   $46
   $46
   $46
   $44
   $44
   $44
   $42
   $0A
   $0A
   $08
   $08
   $08
   $0A
   $0A
   $42
   $44
   $44
   $44
   $46
   $46
   $46
   $0C
   $0C
   $0C
   $0A
   $0A
   $0A
   $08
   $40
   $40
   $42
   $42
   $42
   $44
   $44
   $0C
   $0E
   $0E
   $0E
   $0C
   $0C
   $0C
   $42
   $42
   $42
   $40
   $40
   $40
   $42
   $0A
   $0A
   $0C
   $0C
   $0C
   $0E
   $0E
   $46
   $44
   $44
   $44
   $46
end
 goto gEnd
gEnd
 setupGraphics = 1
 return

MusicSetup
 sdata Music = z
 8,4,19
 8
 2,4,19
 8
 8,4,17
 8
 2,4,17
 8
 8,4,14
 8
 2,4,14
 8
 8,4,15
 8
 2,4,15
 8
 8,4,19
 8
 2,4,19
 8
 8,4,17
 8
 2,4,17
 8
 8,4,14
 8
 2,4,14
 8
 8,4,15
 8
 2,4,15
 8
 8,4,19
 8
 2,4,19
 8
 8,4,17
 8
 2,4,17
 8
 8,4,14
 8
 2,4,14
 8
 8,4,15
 8
 2,4,15
 8
 8,4,17
 15
 0,0,0
 1
 8,4,19
 15
 0,0,0
 1
 8,4,19
 15
 0,0,0
 17

 8,4,19
 8
 2,4,19
 8
 8,4,17
 8
 2,4,17
 8
 8,4,14
 8
 2,4,14
 8
 8,4,15
 8
 2,4,15
 8
 8,4,19
 8
 2,4,19
 8
 8,4,17
 8
 2,4,17
 8
 8,4,14
 8
 2,4,14
 8
 8,4,15
 8
 2,4,15
 8
 8,4,19
 8
 2,4,19
 8
 8,4,17
 8
 2,4,17
 8
 8,4,14
 8
 2,4,14
 8
 8,4,15
 8
 2,4,15
 8
 8,4,17
 15
 0,0,0
 1
 8,4,21
 15
 0,0,0
 1
 8,4,21
 15
 0,0,0
 17

 8,4,19
 8
 2,4,19
 8
 8,4,17
 8
 2,4,17
 8
 8,4,14
 8
 2,4,14
 8
 8,4,15
 8
 2,4,15
 8
 8,4,19
 8
 2,4,19
 8
 8,4,17
 8
 2,4,17
 8
 8,4,14
 8
 2,4,14
 8
 8,4,15
 8
 2,4,15
 8
 8,4,19
 8
 2,4,19
 8
 8,4,17
 8
 2,4,17
 8
 8,4,14
 8
 2,4,14
 8
 8,4,15
 8
 2,4,15
 8
 8,4,17
 15
 0,0,0
 1
 8,4,19
 15
 0,0,0
 1
 8,4,19
 15
 0,0,0
 17

 8,4,21
 23
 2,4,21
 8
 0,0,0
 1
 8,4,21
 15
 0,0,0
 1
 8,4,21
 15
 0,0,0
 1
 8,4,21
 23
 2,4,21
 8
 8,4,21
 15
 0,0,0
 17

 8,4,21
 23
 2,4,21
 8
 0,0,0
 1
 8,4,21
 15
 0,0,0
 1
 8,4,21
 15
 0,0,0
 1
 8,4,21
 23
 2,4,21
 8
 8,4,21
 15
 0,0,0
 17

 8,4,21
 8
 2,4,21
 8
 8,4,19
 8
 2,4,19
 8
 8,4,17
 8
 2,4,17
 8
 8,4,19
 8
 2,4,19
 8
 8,4,21
 8
 2,4,21
 8
 8,4,19
 8
 2,4,19
 8
 8,4,17
 8
 2,4,17
 8
 8,4,19
 8
 2,4,19
 8
 8,4,21
 8
 2,4,21
 8
 8,4,19
 8
 2,4,19
 8
 8,4,17
 8
 2,4,17
 8
 8,4,19
 8
 2,4,19
 8
 8,4,21
 15
 0,0,0
 1
 8,4,21
 15
 0,0,0
 1
 8,4,21
 15
 0,0,0
 17

 255
end
 musicDur = 1
 goto musicSkip

 data SoundRev
 8,1,28
 12
 12,7,20
 16
 8,7,21
 10
 8,7,22
 13
 4,7,24
 15
 2,7,25
 12
 1,7,25
 8
 255
end

 data SoundIdle
 10,14,10
 15
 255
end

 bank 3
 temp1 = temp1

 bank 4
 temp1 = temp1

 bank 5
 temp1 = temp1

 bank 6
