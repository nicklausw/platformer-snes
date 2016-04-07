; the gfx

.include "global.i"

.segment "CODE"

palette:
  .word bgr(0, 0, 0)
  .word bgr(31, 31, 31)
palette_size:

font:
  .incbin "font.chr"
font_size:
