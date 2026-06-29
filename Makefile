all: elf_parser.s 
	nasm -f elf64 -o elf_parser.o elf_parser.s && ld -o elf_parser elf_parser.o

clean:
	rm elf_parser.o elf_parser
