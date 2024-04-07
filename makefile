RM=rm
PORT=/dev/ttyUSB0
SUDO=

BINARY=f256_15
SPRBIN=sprdef.bin
FORCE=-f


SPRITES=1.xpm 2.xpm 3.xpm 4.xpm 5.xpm 6.xpm 7.xpm 8.xpm 9.xpm 10.xpm 11.xpm 12.xpm 13.xpm 14.xpm 15.xpm cursor.xpm joystick.xpm
SPRASM=1.asm 2.asm 3.asm 4.asm 5.asm 6.asm 7.asm 8.asm 9.asm 10.asm 11.asm 12.asm 13.asm 14.asm 15.asm cursor.asm joystick.asm

all: pgz
pgz: $(BINARY).pgz

$(SPRASM): $(SPRITES)
	python xpm2t64.py

$(SPRBIN): $(SPRASM) sprdef.asm
	64tass --nostart -o $(SPRBIN) sprdef.asm

$(BINARY): *.asm
	64tass --nostart -o $(BINARY) main.asm

clean: 
	$(RM) $(FORCE) $(BINARY)
	$(RM) $(FORCE) $(SPRBIN)
	$(RM) $(FORCE) $(BINARY).pgz
	$(RM) $(FORCE) $(SPRASM)

upload: $(BINARY).pgz
	$(SUDO) python fnxmgr.zip --port $(PORT) --run-pgz $(BINARY).pgz

$(BINARY).pgz: $(BINARY) $(SPRBIN)
	python make_pgz.py $(BINARY)
