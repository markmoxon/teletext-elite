
\ ******************************************************************************
\
\       Name: PLOT_PIXEL
\       Type: Macro
\   Category: Teletext Elite
\    Summary: Draw a mode 7 sixel
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   X                   The x-coordinate (0 to 77)
\
\   Y                   The y-coordinate (0 to 74)
\
\ Returns:
\
\   X                   X is preserved
\
\   Y                   Y is preserved
\
\ ******************************************************************************

MACRO PLOT_PIXEL

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

ENDMACRO

\ ******************************************************************************
\
\       Name: PLOT_PIXEL_CLIPPED
\       Type: Macro
\   Category: Teletext Elite
\    Summary: Draw a mode 7 sixel, clipped to the screen boundary
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   X                   The x-coordinate
\
\   Y                   The y-coordinate
\
\ Returns:
\
\   X                   X is preserved
\
\   Y                   Y is preserved
\
\ ******************************************************************************

MACRO PLOT_PIXEL_CLIPPED
{

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

 PLOT_PIXEL

.clip1

}
ENDMACRO

\ ******************************************************************************
\
\       Name: PLOT_SCALE_X
\       Type: Macro
\   Category: Teletext Elite
\    Summary: Scale a pixel x-coordinate to a sixel coordinate
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   A                   The pixel x-coordinate
\
\ Returns:
\
\   A                   The sixel x-coordinate
\
\ ******************************************************************************

MACRO PLOT_SCALE_X

 LSR A                  \ Set A = A / 4, rounded to the nearest integer
 LSR A
 BCC P%+4
 ADC #0

ENDMACRO

\ ******************************************************************************
\
\       Name: PLOT_SCALE_Y
\       Type: Macro
\   Category: Teletext Elite
\    Summary: Scale a pixel y-coordinate to a sixel coordinate, moving it down
\             a row to skip the border row along the top of the screen
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   A                   The pixel y-coordinate
\
\ Returns:
\
\   A                   The sixel y-coordinate
\
\ ******************************************************************************

MACRO PLOT_SCALE_Y

 LSR A                  \ Set A = A / 4, rounded to the nearest integer
 LSR A
 BCC P%+4
 ADC #0

 ADC #3                 \ Move everything down one character row, so we don't
                        \ draw pixels on the title row

ENDMACRO
