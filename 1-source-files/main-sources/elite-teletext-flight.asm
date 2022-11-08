
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

 LDA #LO(dashboard)     \ Set P(1 0) to the dashboard source
 STA P
 LDA #HI(dashboard)
 STA P+1

 LDA #LO(MODE7_VRAM+(18*&28))   \ Set R(1 0) to the dashboard on-screen
 STA R
 LDA #HI(MODE7_VRAM+(18*&28))
 STA R+1

 LDY #0                 \ Set a byte counter in Y

.dash1

 LDA (P),Y              \ Copy the X-th byte from P(1 0) to R(1 0)
 STA (R),Y

 DEY                    \ Decrement the byte counter

 BNE dash1              \ Loop back until we have counted a whole page

 INC P+1                \ Point to the next page
 INC R+1

 LDY #24                \ Set a byte counter in X

.dash2

 LDA (P),Y              \ Copy the X-th byte from P(1 0) to R(1 0)
 STA (R),Y

 DEY                    \ Decrement the byte counter

 BPL dash2              \ Loop back until we have counted X bytes

 LDA #0                 \ Unset the compass colour so we don't try to remove the
 STA COMC               \ existing dot (as there isn't one)

 JSR DIALS              \ Update the contents of the dashboard

 RTS                    \ Return from the subroutine

\ ******************************************************************************
\
\       Name: DrawMissiles
\       Type: Subroutine
\   Category: Teletext Elite
\    Summary: Draw the missiles on the dashboard
\
\ ******************************************************************************

.DrawMissiles

 LDA MSAR               \ If MSAR is zero, missile is not looking for a target,
 BEQ dmis1              \ so jump to dmis1

 LDA #147               \ Set missile colour to yellow
 BNE dmis3

.dmis1

 LDA MSTG               \ If MSTG is 1-12, we have target lock, so jump to
 BPL dmis2              \ dmis2

 LDA #146               \ Set missile colour to green
 BNE dmis3

.dmis2

 LDA #145               \ Set missile colour to red

.dmis3

 STA &7FC3              \ Set the missiles to the colour in A

 JSR msblob             \ Draw the missiles

 RTS                    \ Return from the subroutine
