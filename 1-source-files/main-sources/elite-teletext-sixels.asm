\ ******************************************************************************
\
\ TELETEXT ELITE SIXEL ROUTINES
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
\ The code in this section is mostly taken from the Bitshifters' sixel-plotting
\ routines here:
\
\ https://github.com/bitshifters/teletextr/blob/master/lib/mode7_plot_pixel.asm
\
\ It has been reformatted and has been tweaked to work with Teletext Elite (to
\ support EOR plotting, screen indents and so on), but the core routines are
\ mostly unchanged from the original.
\
\ ******************************************************************************

MODE7_VRAM = &7C00      \ The start of video RAM for mode 7

MODE7_INDENT = 3        \ Width of the left indent in characters to apply to the
                        \ entire space view (so it gets centred)

MODE7_LOW_X = 2         \ The first sixel x-coordinate we can draw sixels in

MODE7_HIGH_X = 2*40 - 2 \ The last sixel x-coordinate we can draw sixels in + 1,
                        \ less 2 to compensate for the first character on each
                        \ row being a graphics control code

MODE7_LOW_Y = 3         \ The first sixel y-coordinate we can draw sixels in (so
                        \ we not draw on the first character row)

MODE7_HIGH_Y = 3*25     \ The last sixel y-coordinate we can draw sixels in + 1

MESSAGE_ROW = 17        \ The character row containing the in-flight message bar

\ ******************************************************************************
\
\       Name: ySixelLo
\       Type: Variable
\   Category: Teletext Elite
\    Summary: Lookup table to convert a sixel y-coordinate into a mode 7 screen
\             address (low byte)
\
\ ******************************************************************************

.ySixelLo

FOR i, 0, MODE7_HIGH_Y-1

 y = (i DIV 3) * 40 + 1 + MODE7_INDENT  \ Add 1 to skip the graphics character
                                        \ in column 0, and then add the screen
                                        \ indent

 EQUB LO(y-i)           \ Adjust for (ZP),Y style addressing, where Y will be
                        \ the y-coordinate
NEXT

\ ******************************************************************************
\
\       Name: ySixelHi
\       Type: Variable
\   Category: Teletext Elite
\    Summary: Lookup table to convert a sixel y-coordinate into a mode 7 screen
\             address (high byte)
\
\ ******************************************************************************

.ySixelHi

FOR i, 0, MODE7_HIGH_Y-1

 y = (i DIV 3) * 40 + 1 + MODE7_INDENT  \ Add 1 to skip the graphics character
                                        \ in column 0, and then add the screen
                                        \ indent

 EQUB HI(y-i)           \ Adjust for (ZP),Y style addressing, where Y will be
                        \ the y-coordinate
NEXT

\ ******************************************************************************
\
\       Name: xSixel
\       Type: Variable
\   Category: Teletext Elite
\    Summary: Lookup table to convert a sixel x-coordinate into a mode 7 screen
\             address, as a row offset
\
\ ******************************************************************************

.xSixel

FOR i, 0, MODE7_HIGH_X-1

 y = i>>1
 EQUB LO(y)

NEXT 

\ ******************************************************************************
\
\       Name: xSixelChar
\       Type: Variable
\   Category: Teletext Elite
\    Summary: Lookup table to return a sixel character containing the relevant
\             three-sixel column containing that x-coordinate, pre-filled with
\             all three sixels populated
\
\ ******************************************************************************

.xSixelChar

FOR n, 0, MODE7_HIGH_X-1

 IF (n AND 1) == 0
  EQUB 32+1+4+16        \ Left column mask (i.e. all three left sixels set)
 ELSE
  EQUB 32+2+8+64        \ Right column mask (i.e. all three rights sixel set)
 ENDIF

NEXT

\ ******************************************************************************
\
\       Name: ySixelChar
\       Type: Variable
\   Category: Teletext Elite
\    Summary: Lookup table to return a sixel character containing the relevant
\             two-sixel row containing that y-coordinate, pre-filled with both
\             sixels populated
\
\ ******************************************************************************

.ySixelChar

FOR n, 0, MODE7_HIGH_Y-1

 IF (n MOD 3) == 0
  EQUB 32+1+2           \ Top row mask (i.e. both top sixels set)
 ELIF (n MOD 3) == 1
  EQUB 32+4+8           \ Middle row mask (i.e. both middle sixels set)
 ELSE
  EQUB 32+16+64         \ Bottom row mask (i.e. both bottom sixels set)
 ENDIF

NEXT

\ ******************************************************************************
\
\       Name: charRowAddress
\       Type: Variable
\   Category: Teletext Elite
\    Summary: Lookup table to return the screen address of the start of a mode 7
\             character row, for printing text
\
\ ******************************************************************************

.charRowAddress

FOR n, 0, 25

 EQUW MODE7_VRAM + MODE7_INDENT + (n*&28)

NEXT

\ ******************************************************************************
\
\       Name: PlotSixelClipped
\       Type: Subroutine
\   Category: Teletext Elite
\    Summary: Plot a mode 7 sixel
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   X                   Sixel x-coordinate
\
\   Y                   Sixel y-coordinate
\
\ ******************************************************************************

.PlotSixelClipped

IF NOT(_DOCKED) AND NOT(_LOADER)

 CPY #MESSAGE_ROW*3     \ In flight, do not draw on the message row
 BEQ clip1
 CPY #MESSAGE_ROW*3+1
 BEQ clip1
 CPY #MESSAGE_ROW*3+2
 BEQ clip1

ENDIF

 CPX #MODE7_LOW_X       \ If the sixel is off-screen, jump to clip1 to return
 BCC clip1              \ from the subroutine
 CPY #MODE7_LOW_Y
 BCC clip1
 CPX #MODE7_HIGH_X
 BCS clip1
 CPY #MODE7_HIGH_Y
 BCS clip1

IF _LOADER

 CLC                    \ Set ZP(1 0) to the screen address of the character
 LDA xSixel,X           \ block, starting with the low byte
 ADC ySixelLo,Y
 STA ZP

 LDA ySixelHi,Y         \ And then the high byte
 ADC #HI(MODE7_VRAM)
 STA ZP+1

ELSE

 CLC                    \ Set SC(1 0) to the screen address of the character
 LDA xSixel,X           \ block, starting with the low byte
 ADC ySixelLo,Y
 STA SC

 LDA ySixelHi,Y         \ And then the high byte
 ADC #HI(MODE7_VRAM)
 STA SCH

ENDIF

 LDA ySixelChar,Y       \ Get the sixel character with the relevant row
                        \ pre-filled for the y-coordinate in Y

 AND xSixelChar,X       \ Apply the sixel character with the relevant column
                        \ pre-filled for the x-coordinate in X, so the result
                        \ is a sixel character with the sixel at (x, y) filled

.sixelLogic

                        \ This label enables us to modify the logic used to draw
                        \ the sixel, for use in the charts

IF _LOADER

 ORA (ZP),Y             \ OR the sixel into the screen, overwriting whatever is
 STA (ZP),Y             \ already there

ELSE

 EOR (SC),Y             \ EOR the sixel into the screen, flipping whatever is
 ORA #%00100000         \ already there
 STA (SC),Y

ENDIF

.clip1

 RTS                    \ Return from the subroutine
