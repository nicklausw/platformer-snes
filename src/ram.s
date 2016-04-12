.include "global.i"

.segment "ZEROPAGE"
  msg_ram: .res 2
  rle_cp_src: .res 2    ; Renamed: serves as pointer (within current bank) to compressed data
  rle_cp_index: .res 2  ; Renamed: serves as index into rle_cp_dat
  
.segment "BSS7E" : far
  rle_cp_dat: .res 8192 ; 8 KB?
