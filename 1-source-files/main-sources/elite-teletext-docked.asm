\ ******************************************************************************
\
\ TELETEXT ELITE DOCKED-SPECIFIC ROUTINES
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
\ ******************************************************************************

\ ******************************************************************************
\
\       Name: PlotSixelIfEmpty
\       Type: Subroutine
\   Category: Teletext Elite
\    Summary: Plot a mode 7 sixel, but only if the character block containing
\             the sixel is empty
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
\                           already something there or the sixel is off-screen
\
\                         * Set if we did plot the sixel
\
\ ******************************************************************************

.PlotSixelIfEmpty

 CPX #MODE7_LOW_X       \ If the sixel is off-screen, jump to empt2 to return
 BCC empt2              \ from the subroutine with the Z flag clear
 CPY #MODE7_LOW_Y
 BCC empt2
 CPX #MODE7_HIGH_X
 BCS empt2
 CPY #MODE7_HIGH_Y
 BCS empt2

 CLC                    \ Set SC(1 0) to the screen address of the character
 LDA xSixel,X           \ block, starting with the low byte
 ADC ySixelLo,Y
 STA SC

 LDA ySixelHi,Y         \ And then the high byte
 ADC #HI(MODE7_VRAM)
 STA SCH

 LDA (SC),Y             \ Fetch the current character from screen memory

 BNE empt1              \ If it is non-zero, i.e. there is something already
                        \ there, jump to empt1 to return from the subroutine
                        \ with the Z flag clear

 LDA ySixelChar,Y       \ Get the sixel character with the relevant row
                        \ pre-filled for the y-coordinate in Y

 AND xSixelChar,X       \ Apply the sixel character with the relevant column
                        \ pre-filled for the x-coordinate in X, so the result
                        \ is a sixel character with the sixel at (x, y) filled

 ORA (SC),Y             \ OR the sixel into the screen, overwriting whatever is
 STA (SC),Y             \ already there

 LDA #0                 \ Set A = 0 so we return with the Z flag set

.empt1

 RTS                    \ Return from the subroutine

.empt2

 LDA #1                 \ Set A = 1 so we return with the Z flag clear

 RTS                    \ Return from the subroutine
