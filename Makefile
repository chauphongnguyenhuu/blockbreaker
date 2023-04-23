PROJECT			:= blockbreaker
ASSEMBLER 		:= nasm
OBJ_FORMAT 		:= elf64
DBG_FORMAT 		:= dwarf
ASSFLAGS		:= -f$(OBJ_FORMAT) -g$(DBG_FORMAT)

LDFLAGS			:= -dynamic-linker
LDLIBS 			:= /lib64/ld-linux-x86-64.so.2 /usr/lib/x86_64-linux-gnu/libX11.so.6

.PHONY: all clean

all: $(PROJECT)

$(PROJECT): main.o
	ld main.o $(LDFLAGS) $(LDLIBS) -o $(PROJECT)

main.o: main.asm
	$(ASSEMBLER) $(ASSFLAGS) main.asm

clean:
	rm -rf *.o $(PROJECT)
