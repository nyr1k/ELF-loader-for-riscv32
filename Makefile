.PHONY: all test clean 

all: elf_parser test/test

elf_parser: elf_parser.s
	nasm -f elf64 -o elf_parser.o elf_parser.s && ld -o elf_parser elf_parser.o
	
test/test: test/test.s
	nasm -f elf32 -o test/test.o test/test.s && ld -m elf_i386 -o test/test test/test.o

test: elf_parser test/test
	@./elf_parser test/test

clean:
	rm elf_parser.o elf_parser test/test test/test.o
