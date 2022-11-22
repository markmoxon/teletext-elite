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
 y = (i DIV 3) * 40 + 1 + MODE7_INDENT \ +1 due to graphics chr, plus indent
 EQUB LO(y-i)   \ adjust for (zp),Y style addressing, where Y will be the y coordinate
NEXT

.pixel_ytable_hi

FOR i, 0, MODE7_HIGH_Y-1
 y = (i DIV 3) * 40 + 1 + MODE7_INDENT \ +1 due to graphics chr, plus indent
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

\ ******************************************************************************
\
\       Name: PlotPixelClipped
\       Type: Subroutine
\   Category: Teletext Elite
\    Summary: Plot a mode 7 pixel
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

.PlotPixelClipped

IF NOT(_DOCKED) AND NOT(_LOADER)

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
 STA SC

 LDA pixel_ytable_hi,Y  \ And then the high byte
 ADC #HI(MODE7_VRAM)
 STA SCH

 LDA pixel_ytable_chr,Y \ Get 2-pixel wide teletext glyph for y-coordinate
 AND pixel_xtable_chr,X \ Apply odd/even x-coordinate mask

.pixelLogic

IF _LOADER

 ORA (SC),Y             \ OR the sixel into the screen
 STA (SC),Y

ELSE

 EOR (SC),Y             \ EOR the sixel into the screen
 ORA #%00100000
 STA (SC),Y

ENDIF

.clip1

 RTS                    \ Return from the subroutine
