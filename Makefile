PROJECT			:= blockbreaker
ASSEMBLER 		:= nasm
OBJ_FORMAT 		:= elf64
DBG_FORMAT 		:= dwarf
ASSFLAGS		:= -f$(OBJ_FORMAT) -g$(DBG_FORMAT)

LDLIBS 			:= /lib64/ld-linux-x86-64.so.2 /usr/lib/x86_64-linux-gnu/libX11.so.6
LDFLAGS			:= -dynamic-linker $(LDLIBS)

.PHONY: all clean

all: $(PROJECT)

$(PROJECT): main.o utils.o graphics.o
	ld main.o utils.o graphics.o $(LDFLAGS) -o $(PROJECT)

main.o: main.asm
	$(ASSEMBLER) $(ASSFLAGS) main.asm

utils.o: utils.asm
	$(ASSEMBLER) $(ASSFLAGS) utils.asm

graphics.o: graphics.asm
	$(ASSEMBLER) $(ASSFLAGS) graphics.asm

clean:
	rm -rf *.o $(PROJECT)
