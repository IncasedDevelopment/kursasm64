CC=gcc
ASM=nasm
ASMFLAGS=-f elf64 -g
PROGS=hello cw06-01 cw06-02 cw06-03 cw06-04 

all: $(PROGS)

hello: hello.o
	ld -m elf_x86_64 $^ -o $@

%.o: %.asm
	$(ASM) $(ASMFLAGS) $^ -o $@

%: %.o
	$(CC) $^ -o $@

clean:
	rm -f *.o $(PROGS) *~

.PHONY: all clean
