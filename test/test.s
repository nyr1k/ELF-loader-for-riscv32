section .data 
  testMsg db "Hello test world!", 10
  
section .text
  global _start 

_start:
  mov eax, 4
  mov ebx, 1
  mov ecx, testMsg
  mov edx, 18 
  int 0x80
  
  mov eax, 1
  mov ebx, 0
  int 0x80
