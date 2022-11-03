MODE7_VRAM_START = &7C00

TEXEL_LOW_X = 2         \ First texel x-coordinate we can draw texels in

TEXEL_HIGH_X = 2*40 - 2 \ Last texel x-coordinate we can draw texels in + 1
                        \ -2 to compensate for 1st char being graphics control
                        \ code

TEXEL_LOW_Y = 3         \ First texel y-coordinate we can draw texels on (so do
                        \ not draw on the first character row)

TEXEL_HIGH_Y = 3*25     \ Last texel y-coordinate we can draw texels on + 1

\ ******************************************************************************
\
\       Name: Mode 7 plotting workspace
\       Type: Workspace
\   Category: Teletext Elite
\    Summary: Mode 7 plotting variables and tables
\
\ ******************************************************************************

.plot_pixel_ytable_lo

FOR i, 0, TEXEL_HIGH_Y-1
 y = (i DIV 3) * 40 + 1 \ +1 due to graphics chr
 EQUB LO(y-i)           \ adjust for (zp),Y style addressing, where Y will be the y coordinate
NEXT

.plot_pixel_ytable_hi

FOR i, 0, TEXEL_HIGH_Y-1
 y = (i DIV 3) * 40 + 1 \ +1 due to graphics chr
 EQUB HI(y-i)           \ adjust for (zp),Y style addressing, where Y will be the y coordinate
NEXT

.plot_pixel_ytable_chr

FOR n, 0, TEXEL_HIGH_Y-1
 IF (n MOD 3) == 0
  EQUB 32+1+2           \ Top row mask
 ELIF (n MOD 3) == 1
  EQUB 32+4+8           \ Middle row mask
 ELSE
  EQUB 32+16+64         \ Bottom row mask
 ENDIF 
NEXT

.plot_pixel_xtable

FOR i, 0, TEXEL_HIGH_X-1
 y = i>>1
 EQUB LO(y)
NEXT 

.plot_pixel_xtable_chr

FOR n, 0, TEXEL_HIGH_X-1
 IF (n AND 1) == 0
  EQUB 32+1+4+16        \ Left hand column mask (even pixels)
 ELSE
  EQUB 32+2+8+64        \ Right hand column mask (odd pixels)
 ENDIF 
NEXT

.plot_row_address

FOR n, 0, 25
 EQUW &7C00 + (n*&28)   \ Screen address of the start of row n in mode 7
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

 STA MODE7_VRAM_START,X         \ Zero the X-th byte of each of the four pages
 STA MODE7_VRAM_START+&100,X    \ in a mode 7 screen
 STA MODE7_VRAM_START+&200,X
 STA MODE7_VRAM_START+&300,X

 INX                    \ Increment the byte counter

 BNE clrs1              \ Loop back until we have counted a whole page

                        \ Fall into ClearOneLineTitle to style the title line

\ ******************************************************************************
\
\       Name: ClearOneLineTitle
\       Type: Subroutine
\   Category: Teletext Elite
\    Summary: Print the control codes for the first line of a two-line title
\
\ ******************************************************************************

.ClearOneLineTitle

 LDA #132               \ Row 0: Yellow text on blue background
 STA MODE7_VRAM_START
 LDA #157
 STA MODE7_VRAM_START+1
 LDA #131
 STA MODE7_VRAM_START+2

 LDA #151               \ Row 1: White graphics
 STA MODE7_VRAM_START+&28

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: ClearTwoLineTitle
\       Type: Subroutine
\   Category: Teletext Elite
\    Summary: Print the control codes for the second line of a two-line title
\
\ ******************************************************************************

.ClearTwoLineTitle

 LDA #132               \ Row 0: Yellow text on blue background
 STA MODE7_VRAM_START+&28
 LDA #157
 STA MODE7_VRAM_START+&29
 LDA #131
 STA MODE7_VRAM_START+&2A

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

 FOR n, 2, 24
  STA MODE7_VRAM_START + n*40   \ Set row 2 onwards to white graphics
 NEXT

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
 PLOT_PIXEL_CLIPPED

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
 PLOT_PIXEL_CLIPPED
 
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

 LDX #131               \ Set X to the "white text" control code

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

 ASL A                  \ Add the row address for YC (from the plot_row_address
 TAY                    \ table) to SC to give the screen address of the
 LDA plot_row_address,Y \ character
 STA SC
 LDA plot_row_address+1,Y
 STA SCH

 LDY XC                 \ Store the character in X at the XC-th character on the
 TXA                    \ row at SC(1 0)
 STA (SC),Y

 INC XC                 \ Move the text cursor to the right

 RTS                    \ Return from the subroutine