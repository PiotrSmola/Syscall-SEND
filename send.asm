section .data
    server_msg db "Wiadomosc od serwera!", 0xA, 0
    server_msg_len equ $ - server_msg
    server_optval dq 1             ; wartosc dla SO_REUSEADDR
    msg_listening db "Serwer nasluchuje polaczen...", 0xA, 0
    msg_listening_len equ $ - msg_listening
    msg_client_accepted db "Polaczenie z klientem zaakceptowane.", 0xA, 0
    msg_client_accepted_len equ $ - msg_client_accepted
    msg_sent db "Wiadomosc wyslana do klienta.", 0xA, 0
    msg_sent_len equ $ - msg_sent

section .bss
    server_fd resq 1
    client_fd resq 1
    server_addr resb 16

section .text
    global _start

print_message:
    mov rax, 1                    ; syscall: write
    mov rdi, 1                    
    syscall
    ret

_start:
    ; Tworzenie gniazda/socketu
    mov rax, 41                   ; syscall: socket
    mov rdi, 2                    ; domena: AF_INET
    mov rsi, 1                    ; typ: SOCK_STREAM
    mov rdx, 0                    ; protokol: 0 (domyslny TCP)
    syscall
    cmp rax, -1
    je error
    mov [server_fd], rax          ; zapisanie deskryptora gniazda

    ; Ustawienie opcji SO_REUSEADDR
    mov rax, 54                   ; syscall: setsockopt
    mov rdi, [server_fd]          ; deskryptor gniazda
    mov rsi, 1                    ; SOL_SOCKET
    mov rdx, 15                   ; SO_REUSEADDR
    mov r10, server_optval        
    mov r8, 4                     ; dlugosc wartosci opcji
    syscall
    cmp rax, -1
    je error

    ; Ustawienie adresu serwera
    mov rdi, server_addr         ; wskaznik na strukture adresu
    mov word [rdi], 2            ; sin_family: AF_INET

    ; Ustawienie portu na 8081 w big-endianie
    mov ax, 8081                 ; ladowanie portu 8081 do rejestru 16-bitowego
    rol ax, 8                    ; konwersja do big-endian poprzez rotacje bajtow
    mov [rdi + 2], ax            ; zapisywanie skonwertowanej wartosci do sin_port

    ; Ustawienie adresu IP (127.0.0.1 w little-endian)
    mov dword [rdi + 4], 0x0100007F

    ; Bindowanie gniazda
    mov rax, 49                   ; syscall: bind
    mov rdi, [server_fd]
    mov rsi, server_addr
    mov rdx, 16                   
    syscall
    cmp rax, -1
    je error

    ; Nasluchiwanie polaczen
    mov rax, 50                   ; syscall: listen
    mov rdi, [server_fd]
    mov rsi, 1                    ; backlog: 1
    syscall
    cmp rax, -1
    je error

    lea rsi, [msg_listening]      ; ustawienie komunikatu do wyswietlenia
    mov rdx, msg_listening_len    
    call print_message

    ; Akceptowanie polaczenia
    mov rax, 43                   ; syscall: accept
    mov rdi, [server_fd]
    xor rsi, rsi                  
    xor rdx, rdx                  
    syscall
    cmp rax, -1
    je error
    mov [client_fd], rax          ; zapisanie deskryptora klienta

    lea rsi, [msg_client_accepted]      ; ustawienie komunikatu do wyswietlenia
    mov rdx, msg_client_accepted_len    
    call print_message

    ; Wysylanie wiadomosci do podlaczonego klienta
    mov rax, 44                   ; syscall: send
    mov rdi, [client_fd]
    lea rsi, [server_msg]         ; wskaznik na wiadomosc
    mov rdx, server_msg_len       
    xor r10, r10                  ; flags: 0
    syscall
    cmp rax, -1
    je error

    lea rsi, [msg_sent]           ; ustawienie komunikatu do wyswietlenia
    mov rdx, msg_sent_len         
    call print_message

    ; Zamkniecie gniazda/socketu klienta
    mov rax, 3                    ; syscall: close
    mov rdi, [client_fd]
    syscall

    ; Zamkniecie gniazda/socketu serwera
    mov rax, 3                    ; syscall: close
    mov rdi, [server_fd]
    syscall

    ; Wyjscie z programu
    mov rax, 60                   ; syscall: exit
    xor rdi, rdi
    syscall

error:
    mov rax, 60                   ; syscall: exit
    mov rdi, 1                    ; kod wyjscia 1 (wyrzucenie bledu)
    syscall