.PHONY: all test clean 

all: elf_parser 

elf_parser: elf_parser.s
	nasm -f elf64 -o elf_parser.o elf_parser.s && ld -o elf_parser elf_parser.o
	
test: elf_parser 
	@./elf_parser test/test_program.elf

clean:
	rm elf_parser.o elf_parser 
