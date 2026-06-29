section .data
  testMsg db "Hello World", 10 
  newline db 10 

section .text
  global _start 

_start:

  ; if argc != 2 -> exit 
  cmp qword [rsp], 2
  jne exit_error 

  ; print test message 
  mov rax, 1 
  mov rdi, 1 
  mov rsi, testMsg
  mov rdx, 12 
  syscall  

  ; pass the argument string to strlen 
  mov rdi, [rsp+16] 
  call strlen 
 
  ; print the argument string 
  mov rdx, rax ; string length 
  mov rsi, rdi ; pass the string
  mov rax, 1 ; sys_write
  mov rdi, 1 ; fd 1 ->  stdout
  syscall  

  ; print newline
  mov rax, 1
  mov rdi, 1
  mov rsi, newline
  mov rdx, 1
  syscall 
  
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
