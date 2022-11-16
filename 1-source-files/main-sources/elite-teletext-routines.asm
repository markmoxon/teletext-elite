MODE7_VRAM = &7C00

MODE7_INDENT = 3        \ Width of left indent in characters

MODE7_LOW_X = 2         \ First sixel x-coordinate we can draw sixels in

MODE7_HIGH_X = 2*40 - 2 \ Last sixel x-coordinate we can draw sixels in + 1
                        \ -2 to compensate for 1st char being graphics control
                        \ code

MODE7_LOW_Y = 3         \ First sixel y-coordinate we can draw sixels on (so do
                        \ not draw on the first character row)

MODE7_HIGH_Y = 3*25     \ Last sixel y-coordinate we can draw sixels on + 1

MESSAGE_ROW = 17        \ Configure the row for the message bar

\ ******************************************************************************
\
\       Name: Mode 7 plotting workspace
\       Type: Workspace
\   Category: Teletext Elite
\    Summary: Mode 7 plotting variables and tables
\
\ ******************************************************************************

.pixel_ytable_lo

FOR i, 0, MODE7_HIGH_Y-1
 y = (i DIV 3) * 40 + 1 \ +1 due to graphics chr
 EQUB LO(y-i)           \ adjust for (zp),Y style addressing, where Y will be the y coordinate
NEXT

.pixel_ytable_hi

FOR i, 0, MODE7_HIGH_Y-1
 y = (i DIV 3) * 40 + 1 \ +1 due to graphics chr
 EQUB HI(y-i)           \ adjust for (zp),Y style addressing, where Y will be the y coordinate
NEXT

.pixel_ytable_chr

FOR n, 0, MODE7_HIGH_Y-1
 IF (n MOD 3) == 0
  EQUB 32+1+2           \ Top row mask
 ELIF (n MOD 3) == 1
  EQUB 32+4+8           \ Middle row mask
 ELSE
  EQUB 32+16+64         \ Bottom row mask
 ENDIF 
NEXT

.pixel_xtable

FOR i, 0, MODE7_HIGH_X-1
 y = i>>1
 EQUB LO(y)
NEXT 

.pixel_xtable_chr

FOR n, 0, MODE7_HIGH_X-1
 IF (n AND 1) == 0
  EQUB 32+1+4+16        \ Left hand column mask (even pixels)
 ELSE
  EQUB 32+2+8+64        \ Right hand column mask (odd pixels)
 ENDIF 
NEXT

.char_row_address

\ Screen address of the start of row n in mode 7, for plotting text

FOR n, 0, 25
 EQUW MODE7_VRAM + MODE7_INDENT + (n*&28)
NEXT

.rtw_startx

 SKIP 1

.rtw_starty

 SKIP 1

.rtw_endx

 SKIP 1

.rtw_endy

 SKIP 1

.rtw_dx

 SKIP 1

.rtw_dy

 SKIP 1

.rtw_accum

 SKIP 1

.rtw_count

 SKIP 1

\ ******************************************************************************
\
\       Name: PlotPixelClipped
\       Type: Subroutine
\   Category: Teletext Elite
\    Summary: Plot a mode 7 pixel
\
\ ******************************************************************************

.PlotPixelClipped

IF NOT(_DOCKED)

 CPY #MESSAGE_ROW*3     \ In flight, do not draw on the message row
 BEQ clip1
 CPY #MESSAGE_ROW*3+1
 BEQ clip1
 CPY #MESSAGE_ROW*3+2
 BEQ clip1

ENDIF

 CPX #MODE7_LOW_X       \ If pixel is off-screen, do not plot it
 BCC clip1

 CPY #MODE7_LOW_Y
 BCC clip1

 CPX #MODE7_HIGH_X
 BCS clip1

 CPY #MODE7_HIGH_Y
 BCS clip1

 CLC                    \ Set SC(1 0) to the screen address of the character
 LDA pixel_xtable,X     \ block, including any indent, starting with the low
 ADC pixel_ytable_lo,Y  \ byte
 ADC #MODE7_INDENT
 STA SC

 LDA pixel_ytable_hi,Y  \ And then the high byte
 ADC #HI(MODE7_VRAM)
 STA SCH

 LDA pixel_ytable_chr,Y \ Get 2-pixel wide teletext glyph for y-coordinate
 AND pixel_xtable_chr,X \ Apply odd/even x-coordinate mask

 EOR (SC),Y             \ EOR the sixel into the screen
 ORA #%00100000
 STA (SC),Y

.clip1

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: DrawTo
\       Type: Subroutine
\   Category: Teletext Elite
\    Summary: Plot a mode 7 line from the graphics cursor to this one
\
\ ******************************************************************************

.DrawTo

 LDA rtw_startx
 STA rtw_endx
 LDA rtw_starty
 STA rtw_endy
 STX rtw_startx
 STY rtw_starty

 JSR DrawMode7Line      \ Draw a mode 7 line from rtw_start to rtw_end

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: MoveTo
\       Type: Subroutine
\   Category: Teletext Elite
\    Summary: Set the position of the graphics cursor
\
\ ******************************************************************************

.MoveTo

 LDA rtw_startx
 STA rtw_endx
 LDA rtw_starty
 STA rtw_endy
 STX rtw_startx
 STY rtw_starty

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: DrawMode7Line
\       Type: Subroutine
\   Category: Teletext Elite
\    Summary: Draw a mode 7 line
\
\ ******************************************************************************

.DrawMode7Line

 ; calc dx = ABS(startx - endx)
 SEC
 LDA rtw_startx
 TAX
 SBC rtw_endx
 BCS posdx
 EOR #255
 ADC #1

.posdx

 STA rtw_dx
 
 ; C=0 if dir of startx -> endx is positive, otherwise C=1
 PHP
 
 ; calc dy = ABS(starty - endy)
 SEC
 LDA rtw_starty
 TAY
 SBC rtw_endy
 BCS posdy
 EOR #255
 ADC #1

.posdy

 STA rtw_dy
 
 ; C=0 if dir of starty -> endy is positive, otherwise C=1
 PHP
 
 ; Coincident start and end points exit early
 ORA rtw_dx
 BNE nonzero

 ; safe exit for coincident points
 PLP
 PLP
 RTS

.nonzero
 
 ; determine which type of line it is
 LDA rtw_dy
 CMP rtw_dx
 BCC shallowline
  
.steepline

 ; self-modify code so that line progresses according to direction remembered earlier
 PLP     ; C=sign of dy
 LDA #&C8   ; INY (goingdown)
 BCC P%+4
 LDA #&88   ; DEY (goingup)
 STA goingupdown
 
 PLP     ; C=sign of dx
 LDA #&E8   ; INX (goingright)
 BCC P%+4
 LDA #&CA   ; DEX (goingleft)
 STA goingleftright

 ; initialise accumulator for 'steep' line
 LDA rtw_dy
 STA rtw_count
 LSR A

.steeplineloop

 STA rtw_accum
 
 ; plot pixel
 JSR PlotPixelClipped

 ; check if done
 DEC rtw_count
 BNE goingupdown

 .exitline
 RTS
 
 ; move up to next line

.goingupdown

 NOP     ; self-modified to INY (goingdown) or DEY (goingup)
 
 ; check move to next pixel column

.movetonextcolumn

 SEC
 LDA rtw_accum
 SBC rtw_dx
 BCS steeplineloop
 ADC rtw_dy
 
 ; move left or right to next pixel column

.goingleftright

 NOP     ; self-modifed to INX (goingright) or DEX (goingleft)
 JMP steeplineloop
 
.shallowline

 ; self-modify code so that line progresses according to direction remembered earlier
 PLP     ; C=sign of dy
 LDA #&C8   ; INY (goingdown)
 BCC P%+4
 LDA #&88   ; DEY (goingup)
 STA goingupdown2
 
 PLP     ; C=sign of dx
 LDA #&E8   ; INX (goingright)
 BCC P%+4
 LDA #&CA   ; DEX (goingleft)
 STA goingleftright2

 ; initialise accumulator for 'steep' line
 LDA rtw_dx
 STA rtw_count
 LSR A

.shallowlineloop

 STA rtw_accum
 
 ; plot pixel in cached byte
 JSR PlotPixelClipped
 
 ; check if done
 DEC rtw_count
 BNE goingleftright2

 .exitline2
 RTS
 
 ; move left or right to next pixel column

.goingleftright2

 NOP     ; self-modifed to INX (goingright) or DEX (goingleft)
 
 ; check whether we move to the next line

.movetonextline

 SEC
 LDA rtw_accum
 SBC rtw_dy
 BCS shallowlineloop
 ADC rtw_dx

 ; move down or up to next line

.goingupdown2

 NOP     ; self-modified to INY (goingdown) or DEY (goingup)
 JMP shallowlineloop

\ ******************************************************************************
\
\       Name: SetTextYellow
\       Type: Subroutine
\   Category: Teletext Elite
\    Summary: Set yellow text
\
\ ******************************************************************************

.SetTextYellow

 LDX #131               \ Set X to the "yellow text" control code

 BNE PrintCharacter     \ Jump to PrintCharacter to set the colour

\ ******************************************************************************
\
\       Name: SetText
\       Type: Subroutine
\   Category: Teletext Elite
\    Summary: Set white text
\
\ ******************************************************************************

.SetText

 LDX #135               \ Set X to the "white text" control code

 EQUB &2C               \ Skip the next instruction

\ ******************************************************************************
\
\       Name: SetGraphicsWhite
\       Type: Subroutine
\   Category: Teletext Elite
\    Summary: Set white graphics
\
\ ******************************************************************************

.SetGraphicsWhite

 LDX #151               \ Set X to the "white graphics" control code

\ ******************************************************************************
\
\       Name: PrintCharacter
\       Type: Subroutine
\   Category: Teletext Elite
\    Summary: Print a teletext character at the current cursor
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   X                   The teletext character to print
\
\ ******************************************************************************

.PrintCharacter

 LDA YC                 \ Fetch YC, the y-coordinate (row) of the text cursor

 CMP #25                \ If character is off-screen, do not print it
 BCS prin1

 ASL A                  \ Add the row address for YC (from the char_row_address
 TAY                    \ table) to SC to give the screen address of the
 LDA char_row_address,Y \ character
 STA P
 LDA char_row_address+1,Y
 STA P+1

 LDY XC                 \ Fetch XC, x-coordinate (column) of the text cursor

 CPY #40                \ If character is off-screen, do not print it
 BCS prin1

 TXA                    \ Store the character in X at the XC-th character on the
 STA (P),Y              \ row at SC(1 0)

 INC XC                 \ Move the text cursor to the right

.prin1

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: ClearMode7Screen
\       Type: Subroutine
\   Category: Teletext Elite
\    Summary: Clear the mode 7 screen
\
\ ******************************************************************************

.ClearMode7Screen

 LDA #0                 \ Set A = 0 so we can zero screen memory

 LDX #0                 \ Set a byte counter in X

.clrs1

 STA MODE7_VRAM,X       \ Zero the X-th byte of each of the four pages in a
 STA MODE7_VRAM+&100,X  \ mode 7 screen
 STA MODE7_VRAM+&200,X
 STA MODE7_VRAM+&300,X

 INX                    \ Increment the byte counter

 BNE clrs1              \ Loop back until we have counted a whole page

                        \ Fall into StyleTitleRow to style the title line

\ ******************************************************************************
\
\       Name: StyleTitleRow
\       Type: Subroutine
\   Category: Teletext Elite
\    Summary: Print the control codes for the first line of a two-line title
\
\ ******************************************************************************

.StyleTitleRow

 LDA QQ11               \ If this is not the death screen, jump to stit1
 CMP #6
 BNE stit1

 LDA #151               \ This is the death screen, so style the top row as
 STA MODE7_VRAM         \ white graphics

 BNE stit2              \ Jump to stit2 to style the second row as white
                        \ graphics (this BNE is effectively a JMP as A is never
                        \ zero)

.stit1

 LDA #132               \ Style the top row as yellow text on blue background
 STA MODE7_VRAM
 LDA #157
 STA MODE7_VRAM+1
 LDA #131
 STA MODE7_VRAM+2

.stit2

 LDA #151               \ Style the second row as white graphics
 STA MODE7_VRAM+(1*&28)

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: StyleTwoLineTitle
\       Type: Subroutine
\   Category: Teletext Elite
\    Summary: Print the control codes for the second line of a two-line title
\
\ ******************************************************************************

.StyleTwoLineTitle

 LDA #132               \ Style the second row as yellow text on blue background
 STA MODE7_VRAM+(1*&28)
 LDA #157
 STA MODE7_VRAM+(1*&28)+1
 LDA #131
 STA MODE7_VRAM+(1*&28)+2

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: StyleMessages
\       Type: Subroutine
\   Category: Teletext Elite
\    Summary: Print the control codes for the in-flight messages line
\
\ ******************************************************************************

.StyleMessages

 LDA #132               \ Message row: Yellow text on blue background
 STA MODE7_VRAM+(MESSAGE_ROW*&28)
 LDA #157
 STA MODE7_VRAM+(MESSAGE_ROW*&28)+1
 LDA #131
 STA MODE7_VRAM+(MESSAGE_ROW*&28)+2

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: ClearMessage
\       Type: Subroutine
\   Category: Teletext Elite
\    Summary: Remove an in-flight message line from the messages bar
\
\ ******************************************************************************

.ClearMessage

 LDA #0                 \ Set A = 0 so we can zero screen memory

 LDX #3                 \ Set a byte counter in X

.mess1

 STA MODE7_VRAM+(MESSAGE_ROW*&28),X    \ Zero the X-th byte of the messages row

 INX                    \ Increment the byte counter

 CPX #&28               \ Loop back until we have cleared the whole row
 BCC mess1

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: ClearLines
\       Type: Subroutine
\   Category: Teletext Elite
\    Summary: Clear lines 21-23 in mode 7
\
\ ******************************************************************************

.ClearLines

 LDA #135               \ Set A to the "white text" control code

 STA MODE7_VRAM+(21*&28)    \ Set rows 21-23 to text
 STA MODE7_VRAM+(22*&28)
 STA MODE7_VRAM+(23*&28)

 LDA #0                 \ Set A = 0 so we can zero screen memory

 LDX #1                 \ Set a byte counter in X, starting from 1 so we skip
                        \ the graphics/text control character

.clyn1

 STA MODE7_VRAM+(21*&28),X    \ Zero the X-th byte of rows 21 to 23
 STA MODE7_VRAM+(22*&28),X
 STA MODE7_VRAM+(23*&28),X

 INX                    \ Increment the byte counter

 CPX #&28               \ Loop back until we have cleared the whole row
 BCC clyn1

 RTS                    \ Return from the subroutine


\ ******************************************************************************
\
\       Name: SetMode7Graphics
\       Type: Subroutine
\   Category: Teletext Elite
\    Summary: Insert a graphics control character on rows 2 onwards
\
\ ******************************************************************************

.SetMode7Graphics

 LDA #151               \ White graphics

IF _DOCKED

 FOR n, 2, 20
  STA MODE7_VRAM + n*40   \ Set rows 2 to 20 to white graphics
 NEXT

ELSE

 FOR n, 2, 24
  STA MODE7_VRAM + n*40   \ Set row 2 to 24 to white graphics
 NEXT

ENDIF

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: DrawSystem
\       Type: Subroutine
\   Category: Teletext Elite
\    Summary: Draw a system character on the Short-Range Chart
\
\ ******************************************************************************

.DrawSystem

 LDA XX12
 PLOT_SCALE_X
 STA XC

 LDA K4
 PLOT_SCALE_Y
 STA YC

 LDX #'O'
\JSR PrintCharacter

 RTS