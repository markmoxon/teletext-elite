
\ ******************************************************************************
\
\       Name: PLOT_PIXEL
\       Type: Macro
\   Category: Teletext Elite
\    Summary: Draw a mode 7 texel
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

 CLC                    \ Set SC(1 0) to screen address of character block
 LDA plot_pixel_xtable,X
 ADC plot_pixel_ytable_lo,Y
 STA SC
 LDA plot_pixel_ytable_hi,Y
 ADC #HI(MODE7_VRAM_START)
 STA SCH

 LDA plot_pixel_ytable_chr,Y    \ Get 2-pixel wide teletext glyph for y-coordinate
 AND plot_pixel_xtable_chr,X    \ Apply odd/even x-coordinate mask

 EOR (SC),Y             \ EOR the texel into the screen
 ORA #%00100000
 STA (SC),Y

ENDMACRO

\ ******************************************************************************
\
\       Name: PLOT_PIXEL_CLIPPED
\       Type: Macro
\   Category: Teletext Elite
\    Summary: Draw a mode 7 texel, clipped to the screen boundary
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   X                   The x-coordinate (clipped to 0 to PLOT_PIXEL_RANGE_X)
\
\   Y                   The y-coordinate (clipped to 0 to PLOT_PIXEL_RANGE_Y
\
\ Returns:
\
\   X                   X is preserved
\
\   Y                   Y is preserved
\
\ ******************************************************************************

MACRO PLOT_PIXEL_CLIPPED

 CPX #PLOT_PIXEL_RANGE_X
 BCS clip1

 CPY #PLOT_PIXEL_RANGE_Y
 BCS clip1

 PLOT_PIXEL

.clip1

ENDMACRO

\ ******************************************************************************
\
\       Name: PLOT_SCALE_X
\       Type: Macro
\   Category: Teletext Elite
\    Summary: Scale a pixel x-coordinate to a texel coordinate
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   A                   The pixel x-coordinate
\
\ Returns:
\
\   A                   The texel x-coordinate
\
\ ******************************************************************************

MACRO PLOT_SCALE_X

 LSR A
 LSR A
 BCC P%+4
 ADC #0

ENDMACRO

\ ******************************************************************************
\
\       Name: PLOT_SCALE_Y
\       Type: Macro
\   Category: Teletext Elite
\    Summary: Scale a pixel y-coordinate to a texel coordinate, moving it down
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
\   A                   The texel y-coordinate
\
\ ******************************************************************************

MACRO PLOT_SCALE_Y

 LSR A
 LSR A
 BCC P%+4
 ADC #0

\ ADC #3

ENDMACRO
