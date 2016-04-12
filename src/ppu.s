.include "global.i"

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