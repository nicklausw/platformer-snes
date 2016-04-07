.include "global.i"

.segment "ZEROPAGE"
  msg_ram: .res 2

.segment "BSS"
  sprite_ram: .res 512
  sprite_ext: .res 32