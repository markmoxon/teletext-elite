MODE7_VRAM_START = &7C00

PLOT_PIXEL_RANGE_X = 2*40 - 2   \ -2 to compensate for 1st char being graphics
                                \  control code

PLOT_PIXEL_RANGE_Y = 3*25

\ ******************************************************************************
\
\       Name: Mode 7 plotting workspace
\       Type: Workspace
\   Category: Teletext Elite
\    Summary: Mode 7 plotting variables and tables
\
\ ******************************************************************************

.plot_pixel_ytable_lo

FOR i, 0, PLOT_PIXEL_RANGE_Y-1
 y = (i DIV 3) * 40 + 1 \ +1 due to graphics chr
 EQUB LO(y-i)           \ adjust for (zp),Y style addressing, where Y will be the y coordinate
NEXT

.plot_pixel_ytable_hi

FOR i, 0, PLOT_PIXEL_RANGE_Y-1
 y = (i DIV 3) * 40 + 1 \ +1 due to graphics chr
 EQUB HI(y-i)           \ adjust for (zp),Y style addressing, where Y will be the y coordinate
NEXT

.plot_pixel_ytable_chr

FOR n, 0, PLOT_PIXEL_RANGE_Y-1
 IF (n MOD 3) == 0
  EQUB 32+1+2           \ Top row mask
 ELIF (n MOD 3) == 1
  EQUB 32+4+8           \ Middle row mask
 ELSE
  EQUB 32+16+64         \ Bottom row mask
 ENDIF 
NEXT

.plot_pixel_xtable

FOR i, 0, PLOT_PIXEL_RANGE_X-1
 y = i>>1
 EQUB LO(y)
NEXT 

.plot_pixel_xtable_chr

FOR n, 0, PLOT_PIXEL_RANGE_X-1
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

 LDA #0
 LDX #0

.clrs1

 STA MODE7_VRAM_START,X
 STA MODE7_VRAM_START+&100,X
 STA MODE7_VRAM_START+&200,X
 STA MODE7_VRAM_START+&300,X

 INX

 BNE clrs1

 RTS

\ ******************************************************************************
\
\       Name: SetMode7Graphics
\       Type: Subroutine
\   Category: Teletext Elite
\    Summary: Insert a graphics control character on each row
\
\ ******************************************************************************

.SetMode7Graphics

 LDA #144+7             \ White graphics

 FOR n, 0, 24
  STA MODE7_VRAM_START + n*40
 NEXT

 RTS

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
 JSR DrawMode7Line

 RTS

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

 RTS

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
\       Name: SetText
\       Type: Subroutine
\   Category: Teletext Elite
\    Summary: Print the text control code at the current cursor
\
\ ******************************************************************************

.SetText

 LDX #135               \ Set X to the "white text" control code

 EQUB &2C               \ Skip the next instruction

\ ******************************************************************************
\
\       Name: SetGraphics
\       Type: Subroutine
\   Category: Teletext Elite
\    Summary: Print the graphics control code at the current cursor
\
\ ******************************************************************************

.SetGraphics

 LDX #151               \ Set X to the "white graphics" control code

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