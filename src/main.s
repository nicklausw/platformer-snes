.include "global.i"

; the code
.segment "CODE"

.proc reset
  
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
  sta rle_cp_src
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
  
  lda #$00
  sta PPUBRIGHT
  
  
  ; we want nmi
  lda #VBLANK_NMI|AUTOREAD
  sta PPUNMI

  cli ; enable interrupts
  
  ; now to fade in!
  
  lda #$01
  
fade_in:
  wai ; wait a frame
  sta PPUBRIGHT
  ina
  cpa #$0f
  bne fade_in
  
?forever:
  wai
  jmp ?forever
.endproc


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
  phb
  phk         ; set data bank to bank 0 (because banks $40-$7D
  plb         ; and $C0-$FF can't reach low memory)
  bit a:NMISTATUS
  plb
  rti
.endproc

;;
; Decompresses data to rle_cp_dat using a simple RLE scheme.
; @param DBR:rle_cp_src pointer to compressed data
; @return rle_cp_index = 4
.proc rle_copy_ram
  setxy16
  seta8
  ldy #$00
  sty rle_cp_index
  tya  ; clear low and high bytes of accumulator

 loop:
  lda (rle_cp_src),y
  cpa #$ff  ; RLE data is terminated by a run length of $FF
  beq done  ; But what does a run length of 0 do?
  tax
  iny
  lda (rle_cp_src),y
  iny
  phy

  ; At this point, Y (source index) is saved on the stack,
  ; A is the byte to write, and X is the length of the run.
  txy
  
  ; no higher byte!
  pha
  seta16
  tya
  and #$ff
  tay
  seta8
  pla
  
  ldx rle_cp_index
  ; And here, Y is the length of the run, A is the byte to write,
  ; and X is the index into the decompression buffer.
rle_inter:
  sta rle_cp_dat,x
  inx
  dey
  bne rle_inter

  stx rle_cp_index
  ply  ; Restore source index
  bra loop
 
done:
  rtl
.endproc