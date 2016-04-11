.include "global.i"

.segment "ZEROPAGE"
  msg_ram: .res 2
  rle_cp_ram: .res 2
  rle_cp_num: .res 2
  
.segment "BSS7E" : far
  rle_cp_dat: .res 8192 ; 8 KB?
