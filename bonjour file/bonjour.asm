section .data
    prompt db "entre ton nom: ", 0      ; Message pour demander le nom
    prompt_len equ $ - prompt          ; Longueur du message
    greeting db "bonjour, ", 0         ; Message d'accueil
    buffer db 50                       ; Espace pour le nom (50 octets max)

section .bss
    input resb 50                      

section .text
    global _start                      

_start:
    mov eax, 4                         
    mov ebx, 1                         
    mov ecx, prompt                    
    mov edx, prompt_len                
    int 0x80                           

    mov eax, 3                         
    mov ebx, 0                         
    mov ecx, input                     
    mov edx, 50                        
    int 0x80                           

    mov eax, 4                         
    mov ebx, 1                         
    mov ecx, greeting                  
    mov edx, 9                         
    int 0x80                           

    mov eax, 4                         
    mov ebx, 1                         
    mov ecx, input                     
    mov edx, 50                        
    int 0x80                          

    mov eax, 1                         
    xor ebx, ebx                       
    int 0x80                           
