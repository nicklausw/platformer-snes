CC = ca65
LD = ld65
FIX = tools/snes-check.py
RLE = tools/rle.py

CFG = snes.cfg

TITLE = platformer

EMU = bsnes

IFILES = $(wildcard inc/*.i)
SFILES = $(wildcard src/*.s)
OFILES = $(subst .s,.o,$(subst src/,obj/,$(SFILES)))

GFX = $(wildcard gfx/*.chr)
RLE_G = $(subst .chr,.rle,$(GFX))

all: $(TITLE).sfc
	$(EMU) $(TITLE).sfc

$(TITLE).sfc: $(OFILES)
	@echo linking to $(TITLE).sfc...
	@$(LD) -o $(TITLE).sfc -C $(CFG) $(OFILES)
	@$(FIX) $(TITLE).sfc

$(SFILES): $(IFILES)
$(SFILES): $(CFG)
$(SFILES): $(RLE_G)

obj/%.o: src/%.s
	@echo assembling file $<...
	@$(CC) -I inc --bin-include-dir gfx -o $@ $<

gfx/%.rle: gfx/%.chr
	@echo convering $< to rle format...
	@$(RLE) $< $@

clean:
	rm -f $(OFILES) $(RLE_G) $(TITLE).sfc
