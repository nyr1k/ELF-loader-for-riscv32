section .data
  testMsg db "Hello World", 10 
  newline db 10 
  elf_header db 52 ; elf header struct for 32-bit elfs 

section .text
  global _start 

_start:
  ; if argc != 2 -> exit 
  cmp qword [rsp], 2
  jne exit_error 

  ; open the ELF file 
  mov rax, 2 ; sys_open
  mov rdi, [rsp+16] ; file name
  mov rsi, 0 ; O_RDONLY
  mov rdx, 0 ; ignore mode
  syscall 
  ; if return value < 0 -> exit 
  cmp rax, 0 
  jl exit_error 
  ; save the file descriptor
  push rax 
  
  ; load the ELF header 
  mov rax, 0 ; sys_read
  mov rdi, [rsp] ; fd
  mov rsi, elf_header ; buffer
  mov rdx, 52 ; bytes to read
  syscall    
  ; if return value < 0 -> exit 
  cmp rax, 0
  jl exit_error

  mov rdi, elf_header 
  call check_header
  

.exit: 
  ; get the file descriptor
  pop rdi  
  ; close the ELF file
  mov rax, 3 ; sys_close
  syscall 
  ; if return value < 0 -> exit
  cmp rax, 0
  jl exit_error

  ; exit successfully 
  mov rax, 60 
  xor edi, edi 
  syscall

;;;
check_header:
  ; check magic numbers
  cmp dword[rdi], 0x464c457f ; this hex is '0x7f ELF' in little-endian mode
  jne exit_error 
  
  ; check bitness and endian mode 
  cmp word[rdi+4], 0x0101 ; 32-bit and little-endian 
  jne exit_error  

  ; file type (must be executalbe) and architecture (must be RISC-V) 
  cmp dword[rdi+16], 0x00F30002 ; 0x02 = Executable file
  jne exit_error

  ret

;;;
strlen:
  xor eax, eax 

.loop: 
  cmp byte [rdi+rax], 0 
  je .done 
  inc rax
  jmp .loop 

.done:
  ret

;;;
exit_error:
  mov rax, 60
  mov rdi, 1
  syscall 
