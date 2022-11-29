\ ******************************************************************************
\
\ TELETEXT ELITE FLIGHT-SPECIFIC ROUTINES
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
\       Name: dashboard
\       Type: Variable
\   Category: Teletext Elite
\    Summary: The mode 7 dashboard image
\
\ ******************************************************************************

.dashboard

 INCBIN "1-source-files/images/P.DIALST.bin"

\ ******************************************************************************
\
\       Name: ShowDashboard
\       Type: Subroutine
\   Category: Teletext Elite
\    Summary: Show the dashboard
\
\ ******************************************************************************

.ShowDashboard

 LDA #LO(dashboard)     \ Set P(1 0) to the blank dashboard image at dashboard
 STA P
 LDA #HI(dashboard)
 STA P+1

 LDA #LO(MODE7_VRAM+(18*&28))   \ Set R(1 0) to the dashboard's on-screen
 STA R                          \ address from row 18 onwards
 LDA #HI(MODE7_VRAM+(18*&28))
 STA R+1

                        \ The dashboard image is 256 + 24 bytes long, so we can
                        \ copy it into memory using two loops, the first for
                        \ 256 bytes and the second for 24 bytes

 LDY #0                 \ Set a byte counter in Y to work through the first page
                        \ (256 bytes) of the dashboard image as we copy it into
                        \ screen memory

.dash1

 LDA (P),Y              \ Copy the Y-th dashboard byte from P(1 0) to R(1 0)
 STA (R),Y

 DEY                    \ Decrement the byte counter

 BNE dash1              \ Loop back until we have copied a whole page

 INC P+1                \ Increment P(1 0) and R(1 0) to point to the next page
 INC R+1                \ in memory

 LDY #24                \ Set a byte counter in Y to work through the next 24
                        \ bytes of the dashboard image as we copy it into screen
                        \ memory

.dash2

 LDA (P),Y              \ Copy the Y-th dashboard byte from P(1 0) to R(1 0)
 STA (R),Y

 DEY                    \ Decrement the byte counter

 BPL dash2              \ Loop back until we have copied 24 bytes

 LDA #0                 \ Unset the compass colour so we don't try to remove the
 STA COMC               \ existing dot (as there isn't one in the dashboard
                        \ image)

 JMP DIALS              \ Update the contents of the dashboard, returning from
                        \ the subroutine using a tail call

\ ******************************************************************************
\
\       Name: DrawMissiles
\       Type: Subroutine
\   Category: Teletext Elite
\    Summary: Draw the missiles on the dashboard
\
\ ******************************************************************************

.DrawMissiles

 LDA MSAR               \ If MSAR is zero, then the missile is not looking for
 BEQ dmis1              \ a target, so jump to dmis1 to set the missile colour
                        \ to green or red

 LDA #147               \ The missile is looking for a target, so set the
                        \ colour in A to yellow

 BNE dmis3              \ Jump to dmis3 to set the missile colour (this BNE is
                        \ effectively a JMP as A is never zero)

.dmis1

 LDA MSTG               \ If MSTG is 1-12, then we have target lock, so jump to
 BPL dmis2              \ dmis2 to set the missile colour to red

 LDA #146               \ The missile does not have target lock, so set the
                        \ colour in A to green

 BNE dmis3              \ Jump to dmis3 to set the missile colour (this BNE is
                        \ effectively a JMP as A is never zero)

.dmis2

 LDA #145               \ The missile has target lock, so set the colour in A
                        \ to red

.dmis3

 STA &7FC3              \ Set the missiles to the colour in A by poking the
                        \ control character in A into the space before the
                        \ missile sixels

 JMP msblob             \ Draw the missiles, returning from the subroutine
                        \ using a tail call

\ ******************************************************************************
\
\       Name: StyleSystemData
\       Type: Subroutine
\   Category: Teletext Elite
\    Summary: Print the control codes to style the Data on System screen
\
\ ******************************************************************************

.StyleSystemData

 LDA &7CA5              \ If the distance is showing, jump to syst1 to style the
 CMP #'D'               \ screen, as everything moves down one line
 BEQ syst1

 LDA #130               \ Set to the "green text" control code

 STA &7CD5              \ Economy

 STA &7D28              \ Government

 STA &7D78              \ Tech level

 STA &7DC8              \ Population

 STA &7E0C              \ Species

 STA &7E70              \ Gross producticity

 STA &7EBC              \ Average radius

 RTS                    \ Return from the subroutine

.syst1

 LDA #130               \ Set to the "green text" control code

 STA &7CAE              \ Distance

 STA &7CD5+40           \ Economy

 STA &7D28+40           \ Government

 STA &7D78+40           \ Tech level

 STA &7DC8+40           \ Population

 STA &7E0C+40           \ Species

 STA &7E70+40           \ Gross producticity

 STA &7EBC+40           \ Average radius

 RTS                    \ Return from the subroutine
