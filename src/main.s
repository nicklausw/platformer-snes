.include "global.i"

; the code
.segment "CODE"

.proc reset
  InitializeSNES
  
  ; forced blank
  seta8
  lda #$8f
  sta PPUBRIGHT
  
  lda #$01
  sta BGMODE     ; mode 0 (four 2-bit BGs) with 8x8 tiles
  stz BGCHRADDR  ; bg planes 0-1 CHR at $0000
  lda #$4000 >> 13
  sta OBSEL      ; sprite CHR at $4000, sprites are 8x8 and 16x16
  lda #>$6000
  sta NTADDR+0   ; plane 0 nametable at $6000
  sta NTADDR+1   ; plane 1 nametable also at $6000
  
  
  
  ; copy palette
  seta8
  stz CGADDR  ; Seek to the start of CGRAM
  setaxy16
  lda #DMAMODE_CGDATA
  ldx #palette & $ffff
  ldy #palette_size-palette
  jsl ppu_copy
  
  ; copy font
  setaxy16
  lda #font & $ffff
  sta rle_cp_ram
  jsl rle_copy_ram
  
  setaxy16
  stz PPUADDR
  
  lda #DMAMODE_PPUDATA
  ldx #.loword(rle_cp_dat)
  ldy 8192
  
  php
  setaxy16
  sta DMAMODE
  stx DMAADDR
  sty DMALEN
  seta8
  lda #.bankbyte(rle_cp_dat)
  sta DMAADDRBANK
  lda #%00000001
  sta COPYSTART
  plp
  
  seta16
  
  lda #$6000|NTXY(1,1)
  sta PPUADDR


  lda #message & $ffff
  sta msg_ram
  jsr scrn_copy
  
  seta16
  lda #$6000|NTXY(0,15)
  sta PPUADDR
  
  lda #ground & $ffff
  sta msg_ram
  jsr scrn_copy
  
done:
  seta8
  
  lda #%00000001  ; enable sprites and plane 0
  sta BLENDMAIN
  
  lda #$0F
  sta PPUBRIGHT
  
  
  ; we want nmi
  ;lda #VBLANK_NMI|AUTOREAD
  ;sta PPUNMI

  ;cli ; enable interrupts
  
?forever:
  jmp ?forever
.endproc

; we'll need this at some point ;3
zero_fill_byte:
  .byte $00

message:
        ;12345678901234567890123456789012
  .byte "Screw you, it's a platformer.", $ff

ground:
  .repeat 32
   .byte '_'
  .endrepeat
  .byte $ff

.proc ppu_copy
  php
  setaxy16
  sta DMAMODE
  stx DMAADDR
  sty DMALEN
  seta8
  phb
  pla
  sta DMAADDRBANK
  lda #%00000001
  sta COPYSTART
  plp
  rts
.endproc


.proc scrn_copy
  setxy16
  ldy #$00

loop: seta8
  lda (msg_ram), y
  cpa #$ff
  beq done
  seta16
  and #$ff ; clear higher bit
  sta PPUDATA
  iny
  jmp loop
  
done:
  rts
.endproc


.proc vblank
  pha
  phx
  phy
  phd
  phb
  php

  lda NMISTATUS ; clear NMI Flag

  plp
  plb
  pld
  ply
  plx
  pla
  rti
.endproc

.proc rle_copy_ram
  setxy16
  seta8
  ldy #$00
  sty rle_cp_num
  lda #0   ; clear Accum. hi-byte
  xba

 loop:
  lda (rle_cp_ram), y
  cpa #$ff
  beq done
  tax
  iny
  lda (rle_cp_ram),y
  bra rle_loop
rle_loop_done:
  iny
  bra loop
 
done:
  rtl

; IN: X = count
;      A = byte
rle_loop:
; INCOMPLETE / WILL NOT WORK (for above mentioned reasons in forum post)
; Please finish reading forum post and reply so we can work out your needs
  phy
  ldy rle_cp_num
rle_inter:
  phx
  phy
  plx
  sta rle_cp_dat,x   ; this is only writes the low byte.
  phx
  ply
  plx
  iny
  dex
  bne rle_inter
  sty rle_cp_num
  ply
  bra rle_loop_done
.endproc