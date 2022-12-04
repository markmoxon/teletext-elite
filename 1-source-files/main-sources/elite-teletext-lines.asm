\ ******************************************************************************
\
\ TELETEXT ELITE LINE ROUTINES
\
\ Elite was written by Ian Bell and David Braben and is copyright Acornsoft 1984
\
\ The code on this site has been reconstructed from a disassembly of the version
\ released on Ian Bell's personal website at http://www.elitehomepage.org/
\
\ The commentary is copyright Mark Moxon, and any misunderstandings or mistakes
\ in the documentation are entirely my fault
\
\ The terminology and notations used in this commentary are explained at
\ https://www.bbcelite.com/about_site/terminology_used_in_this_commentary.html
\
\ The deep dive articles referred to in this commentary can be found at
\ https://www.bbcelite.com/deep_dives
\
\ ------------------------------------------------------------------------------
\
\ The code in this section is taken from the Bitshifters' sixel line-drawing
\ routines here:
\
\ https://github.com/bitshifters/teletextr/blob/master/lib/bresenham.asm
\
\ It has been reformatted, but the core routines and comments are mostly
\ unchanged from the original.
\
\ ******************************************************************************

\ ******************************************************************************
\
\       Name: rtw
\       Type: Workspace
\   Category: Teletext Elite
\    Summary: Variables for use in the Bresenham routine below, based on
\             routines by Rich Talbot-Watkins (hence "rtw")
\
\ ******************************************************************************

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
\       Name: MoveToSixel
\       Type: Subroutine
\   Category: Teletext Elite
\    Summary: Set the position of the graphics cursor to (X, Y)
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   X                   Sixel x-coordinate to move to
\
\   Y                   Sixel y-coordinate to move to
\
\ ******************************************************************************

.MoveToSixel

 LDA rtw_startx         \ Copy the current start coordinate to the end
 STA rtw_endx           \ coordinate
 LDA rtw_starty
 STA rtw_endy

 STX rtw_startx         \ Set the start coordinate to (X, Y)
 STY rtw_starty

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: DrawToSixel
\       Type: Subroutine
\   Category: Teletext Elite
\    Summary: Plot a mode 7 sixel line from the graphics cursor to (X, Y)
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   X                   Sixel x-coordinate to draw to
\
\   Y                   Sixel y-coordinate to draw to
\
\ ******************************************************************************

.DrawToSixel

 LDA rtw_startx         \ Copy the current start coordinate to the end
 STA rtw_endx           \ coordinate
 LDA rtw_starty
 STA rtw_endy

 STX rtw_startx         \ Set the start coordinate to (X, Y)
 STY rtw_starty

 SEC                    \ Calc dx = ABS(startx - endx)
 LDA rtw_startx
 TAX
 SBC rtw_endx
 BCS posdx
 EOR #255
 ADC #1

.posdx

 STA rtw_dx
 
 PHP                    \ C=0 if dir of startx -> endx is positive,
                        \ otherwise C=1
 
 SEC                    \ Calc dy = ABS(starty - endy)
 LDA rtw_starty
 TAY
 SBC rtw_endy
 BCS posdy
 EOR #255
 ADC #1

.posdy

 STA rtw_dy
 
 PHP                    \ C=0 if dir of starty -> endy is positive,
                        \ otherwise C=1
 
 ORA rtw_dx             \ Coincident start and end points exit early
 BNE nonzero

 PLP                    \ Safe exit for coincident points
 PLP
 RTS

.nonzero
 
 LDA rtw_dy             \ Determine which type of line it is
 CMP rtw_dx
 BCC shallowline
  
.steepline

                        \ Self-modify code so that line progresses according to
                        \ direction remembered earlier

 PLP                    \ C=sign of dy
 LDA #&C8               \ INY (goingdown)
 BCC P%+4
 LDA #&88               \ DEY (goingup)
 STA goingupdown
 
 PLP                    \ C=sign of dx
 LDA #&E8               \ INX (goingright)
 BCC P%+4
 LDA #&CA               \ DEX (goingleft)
 STA goingleftright

 LDA rtw_dy             \ Initialise accumulator for 'steep' line
 STA rtw_count
 LSR A

.steeplineloop

 STA rtw_accum
 
 JSR PlotSixelClipped   \ Plot sixel

 DEC rtw_count          \ Check if done
 BNE goingupdown

.exitline

 RTS
 
.goingupdown

                        \ Move up to next line

 NOP                    \ Self-modified to INY (goingdown) or DEY (goingup)

.movetonextcolumn

                        \ Check move to next pixel column

 SEC
 LDA rtw_accum
 SBC rtw_dx
 BCS steeplineloop
 ADC rtw_dy

.goingleftright

                        \ Move left or right to next pixel column

 NOP                    \ Self-modifed to INX (goingright) or DEX (goingleft)

 JMP steeplineloop
 
.shallowline

                        \ Self-modify code so that line progresses according to
                        \ direction remembered earlier

 PLP                    \ C=sign of dy
 LDA #&C8               \ INY (goingdown)
 BCC P%+4
 LDA #&88               \ DEY (goingup)
 STA goingupdown2
 
 PLP                    \ C=sign of dx
 LDA #&E8               \ INX (goingright)
 BCC P%+4
 LDA #&CA               \ DEX (goingleft)
 STA goingleftright2

 LDA rtw_dx             \ Initialise accumulator for 'steep' line
 STA rtw_count
 LSR A

.shallowlineloop

 STA rtw_accum
 
 JSR PlotSixelClipped   \ Plot sixel in cached byte
 
 DEC rtw_count          \ Check if done
 BNE goingleftright2

.exitline2

 RTS
 
.goingleftright2

                        \ Move left or right to next pixel column

 NOP                    \ Self-modifed to INX (goingright) or DEX (goingleft)
 
.movetonextline

                        \ Check whether we move to the next line

 SEC
 LDA rtw_accum
 SBC rtw_dy
 BCS shallowlineloop
 ADC rtw_dx

.goingupdown2

                        \ Move down or up to next line

 NOP                    \ Self-modified to INY (goingdown) or DEY (goingup)

 JMP shallowlineloop
