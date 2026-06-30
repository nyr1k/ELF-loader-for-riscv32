.PHONY: all test clean 

all: elf_loader 

elf_loader: elf_loader.s
	nasm -f elf64 -o elf_loader.o elf_loader.s && ld -o elf_loader elf_loader.o
	
test: elf_loader 
	@./elf_loader test/test_program.elf

clean:
	rm elf_loader.o elf_loader
