; the gfx

.include "global.i"

.segment "RODATA"

palette:
  .word bgr(0, 0, 0)
  .word bgr(31, 31, 31)
palette_size:

font:
  .incbin "font.rle"