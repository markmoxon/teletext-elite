\ ******************************************************************************
\
\ TELETEXT ELITE MACROS
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
\       Name: SCALE_SIXEL_X
\       Type: Macro
\   Category: Teletext Elite
\    Summary: Scale a pixel x-coordinate to a sixel x-coordinate
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   A                   The pixel x-coordinate
\
\ ------------------------------------------------------------------------------
\
\ Returns:
\
\   A                   The sixel x-coordinate
\
\ ******************************************************************************

MACRO SCALE_SIXEL_X

 LSR A                  \ Set A = A / 4, rounded to the nearest integer
 LSR A
 BCC P%+4
 ADC #0

ENDMACRO

\ ******************************************************************************
\
\       Name: SCALE_SIXEL_Y
\       Type: Macro
\   Category: Teletext Elite
\    Summary: Scale a pixel y-coordinate to a sixel y-coordinate, moving it down
\             a row to skip the border row along the top of the screen
\
\ ------------------------------------------------------------------------------
\
\ Arguments:
\
\   A                   The pixel y-coordinate
\
\ ------------------------------------------------------------------------------
\
\ Returns:
\
\   A                   The sixel y-coordinate
\
\ ******************************************************************************

MACRO SCALE_SIXEL_Y

 LSR A                  \ Set A = A / 4, rounded to the nearest integer
 LSR A
 BCC P%+4
 ADC #0

 ADC #3                 \ Move everything down one character row, so we don't
                        \ draw pixels on the title row

ENDMACRO
