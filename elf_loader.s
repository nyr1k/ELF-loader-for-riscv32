section .text
  global _start
  global load_elf 

; edi - memory_size, rsi - *memory, rdx *elf_name 
load_elf:
  push rbp
  push rbx
  push r12
  push r13 
  mov rbp, rsp
  sub rsp, 84 ; elf_header (52 bytes) & program_header (32 bytes) 
  
  ; save arguments before syscalls
  mov r12d, edi
  mov r13, rsi 
 
  ; open the ELF file
  mov eax, 2 ; sys_open
  mov rdi, rdx
  mov esi, 0 ; O_RDONLY
  mov edx, 0 ; no mode
  syscall
  ; return -1 if open fail
  cmp eax, 0 
  mov edi, -1
  jl .return_error
  ; save fd 
  mov ebx, eax  

  ; load the ELF header
  mov eax, 0 ; sys_read
  mov edi, ebx ; fd 
  lea rsi, [rbp-52] ; buffer 
  mov edx, 52 ; read 52 bytes 
  syscall
  ; return -2 if read fail
  cmp eax, 52
  mov edi, -2
  jne .return_error

  lea rdi, [rbp-52] ; pass elf_header 
  ; create struct for e_entry, e_phoff, e_phentrysz, e_phnum
  sub rsp, 12
  lea rsi, [rsp-96] 
  call check_header
  
  add rsp, 96
  pop r13
  pop r12
  pop rbx
  pop rbp
  mov eax, 0
  ret 

.return_error:
  add rsp, 96
  pop r13
  pop r12
  pop rbx
  pop rbp
  mov eax, edi
  ret

_start:
  ; if argc != 2 -> exit 
  cmp qword [rsp], 2
  jne exit_error 

  mov rdx, [rsp+16]
  sub rsp, 8  
  call load_elf
  add rsp, 8
  
  cmp eax, 0
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

  ; if everything's correct -> copy the program header fields
  mov eax, [rdi+24]
  mov dword[rsi], eax 
  
  mov eax, [rdi+28]
  mov dword[rsi+4], eax
  
  mov ax, [rdi+42]
  mov word[rsi+8], ax
  
  mov ax, [rdi+44]
  mov word[rsi+10], ax

.done:
  ret

;;;
exit_error:
  mov rax, 60
  mov rdi, 1
  syscall
 
