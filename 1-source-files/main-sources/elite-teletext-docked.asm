\ ******************************************************************************
\
\       Name: PlotPixelIfEmpty
\       Type: Subroutine
\   Category: Teletext Elite
\    Summary: Plot a mode 7 pixel, but only if the character block containing
\             the pixel is empty
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   X                   Sixel x-coordinate
\
\   Y                   Sixel y-coordinate
\
\ Returns:
\
\   Z flag              Did we plot the sixel?
\
\                         * Clear if we did not plot the sixel because there is
\                           already something there
\
\                         * Set if we did plot the sixel
\
\ ******************************************************************************

.PlotPixelIfEmpty

 CPX #MODE7_LOW_X       \ If pixel is off-screen, do not plot it
 BCC empt1

 CPY #MODE7_LOW_Y
 BCC empt1

 CPX #MODE7_HIGH_X
 BCS empt1

 CPY #MODE7_HIGH_Y
 BCS empt1

 CLC                    \ Set SC(1 0) to the screen address of the character
 LDA pixel_xtable,X     \ block, including any indent, starting with the low
 ADC pixel_ytable_lo,Y  \ byte
 STA SC

 LDA pixel_ytable_hi,Y  \ And then the high byte
 ADC #HI(MODE7_VRAM)
 STA SCH

 LDA (SC),Y             \ Fetch the current character from screen memory

 BNE empt1              \ If it is non-zero, i.e. there is something already
                        \ there, jump to empt1 to return from the subroutine
                        \ with the Z flag clear

 LDA pixel_ytable_chr,Y \ Get 2-pixel wide teletext glyph for y-coordinate
 AND pixel_xtable_chr,X \ Apply odd/even x-coordinate mask

 ORA (SC),Y             \ OR the sixel into the screen
 STA (SC),Y

 LDA #0                 \ Set A = 0 so we return with the Z flag set

.empt1

 RTS                    \ Return from the subroutine
