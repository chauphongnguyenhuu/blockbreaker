PROJECT	:= blockbreaker

ASSEMBLER 	:= nasm
ASMFLAGS	:= -felf64 -gdwarf
LINKER 		:= ld
LDFLAGS		:= -dynamic-linker /lib64/ld-linux-x86-64.so.2 /usr/lib/x86_64-linux-gnu/libX11.so.6

SRCS := $(shell find . -name '*.asm')
OBJS := $(SRCS:%.asm=%.o)

.PHONY: all clean

all: $(PROJECT)

$(PROJECT): $(OBJS)
	$(LINKER) $(OBJS) $(LDFLAGS) -o $(PROJECT)

%.o: %.asm
	$(ASSEMBLER) $(ASMFLAGS) $< -o $@

clean:
	rm -f *.o $(PROJECT)
