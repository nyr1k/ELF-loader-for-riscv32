section .data

section .text
  global _start 

_start:
 
  mov rax, 60 ; exit syscall
  xor edi, edi ; zero exit_code
  syscall  
