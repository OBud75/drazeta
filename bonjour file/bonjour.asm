section .data
    prompt db "entre ton nom: ", 0      ; Message pour demander le nom
    prompt_len equ $ - prompt          ; Longueur du message
    greeting db "bonjour, ", 0         ; Message d'accueil
    buffer db 50                       ; Espace pour le nom (50 octets max)

section .bss
    input resb 50                      ; Réserve de la mémoire pour l'entrée utilisateur

section .text
    global _start                      ; Point d'entrée du programme

_start:
    ; Afficher le message "entre ton nom: "
    mov eax, 4                         ; syscall: write
    mov ebx, 1                         ; fichier: stdout
    mov ecx, prompt                    ; adresse du message
    mov edx, prompt_len                ; taille du message
    int 0x80                           ; appel système

    ; Lire l'entrée utilisateur
    mov eax, 3                         ; syscall: read
    mov ebx, 0                         ; fichier: stdin
    mov ecx, input                     ; adresse pour stocker l'entrée
    mov edx, 50                        ; taille maximum
    int 0x80                           ; appel système

    ; Afficher "bonjour, "
    mov eax, 4                         ; syscall: write
    mov ebx, 1                         ; fichier: stdout
    mov ecx, greeting                  ; adresse du message d'accueil
    mov edx, 9                         ; taille du message (longueur de "bonjour, ")
    int 0x80                           ; appel système

    ; Afficher le nom saisi
    mov eax, 4                         ; syscall: write
    mov ebx, 1                         ; fichier: stdout
    mov ecx, input                     ; adresse de l'entrée utilisateur
    mov edx, 50                        ; taille maximum (ou ajustez pour enlever '\n')
    int 0x80                           ; appel système

    ; Quitter le programme
    mov eax, 1                         ; syscall: exit
    xor ebx, ebx                       ; code de sortie: 0
    int 0x80                           ; appel système
