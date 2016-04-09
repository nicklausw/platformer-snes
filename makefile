CC = ca65
LD = ld65
FIX = tools/snes-check.py

TITLE = platformer

EMU = higan

IFILES = $(wildcard inc/*.i)
SFILES = $(wildcard src/*.s)
OFILES = $(subst .s,.o,$(subst src/,obj/,$(SFILES)))

all: $(TITLE).sfc
	$(EMU) $(TITLE).sfc

$(TITLE).sfc: $(OFILES)
	$(LD) -o $(TITLE).sfc -C snes.cfg $(OFILES)
	$(FIX) $(TITLE).sfc

$(SFILES): $(IFILES)

obj/%.o: src/%.s
	$(CC) -I inc --bin-include-dir gfx -o $@ $<

clean:
	rm -f $(OFILES) $(TITLE).sfc
