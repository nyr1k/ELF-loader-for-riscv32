section .data
  testMsg db "Hello World", 10 
  newline db 10 

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

  push rax ; save the file descriptor
  
  sub rsp, 1024 ; allocate read buffer 

  mov rax, 1
  mov rdi, 1
  mov rsi, testMsg
  mov rdx, 12
  syscall  

  add rsp, 1024 ; deallocate read buffer
  pop rdi ; pop the file descriptor

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
