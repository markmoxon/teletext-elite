
.dashboard

 INCBIN "1-source-files/images/P.DIALST.bin"

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

 RTS