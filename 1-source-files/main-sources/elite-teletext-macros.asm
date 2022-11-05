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
