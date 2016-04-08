; the global file

.include "snes.i"
.include "macros.i"
.p816
.smart
.localchar '?'

; main.s
.global reset, vblank

; gfx.s
.global palette, palette_size
.global font, font_size

; ram.s
.globalzp msg_ram, rle_cp_ram
.global sprite_ram, sprite_ext

; macros

; palette macro
.define bgr(cb, g, r) ((cb<<10)|(g<<5)|r)
