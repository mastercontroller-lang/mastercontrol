section .data
    prompt db "Password: ", 0              ; Password prompt
    correct_password db "secret", 0        ; Hardcoded password
    incorrect_msg db "Authentication failed.", 10, 0
    usage_msg db "Usage: mc <command>", 10, 0
    exec_fail_msg db "Failed to execute command.", 10, 0

section .bss
    input_password resb 64                 ; Buffer for the entered password
    args resq 16                           ; Space for argument pointers

section .text
    global _start

_start:
    ; Check for command-line arguments
    mov rdi, [rsp + 8]                     ; argc
    cmp rdi, 2                             ; At least 1 argument + program name
    jl show_usage

    ; Prompt for password
    mov rsi, input_password
    call prompt_password

    ; Check the entered password
    mov rdi, input_password
    mov rsi, correct_password
    call strcmp
    cmp rax, 0                             ; Password correct?
    jne auth_fail

    ; Execute the command
    mov rdi, [rsp + 16]                    ; Get command (argv[1])
    lea rsi, [rsp + 24]                    ; Get command arguments (argv[2])
    mov [args], rdi                        ; Set args[0] to command
    mov rdx, 0                             ; NULL-terminate args
    mov [args + 8], rdx

    mov rdi, rdi                           ; Command
    lea rsi, [args]                        ; Argument list
    xor rdx, rdx                           ; Environment (NULL)
    mov rax, 59                            ; syscall: execve
    syscall

exec_fail:
    ; If execve fails, print an error message and exit
    mov rdi, exec_fail_msg
    call print
    jmp exit

auth_fail:
    ; If authentication fails, print an error message and exit
    mov rdi, incorrect_msg
    call print
    jmp exit

show_usage:
    ; Print usage message
    mov rdi, usage_msg
    call print
    jmp exit

exit:
    mov rax, 60                            ; syscall: exit
    xor rdi, rdi                           ; exit code 0
    syscall

; Helper: Print a string
print:
    mov rsi, rdi                           ; Message to print
    mov rdx, strlen(rsi)                   ; Calculate length
    mov rax, 1                             ; syscall: write
    mov rdi, 1                             ; File descriptor: stdout
    syscall
    ret

; Helper: Prompt for password
prompt_password:
    mov rdi, prompt
    call print

    mov rax, 0                             ; syscall: read
    mov rdi, 0                             ; File descriptor: stdin
    syscall
    ret

; Helper: Compare two strings
strcmp:
    mov rax, 0
.next_char:
    mov al, byte [rdi]                     ; Load byte from first string
    cmp al, byte [rsi]                     ; Compare with second string
    jne .diff                              ; If not equal, strings differ
    test al, al                            ; End of string?
    je .equal                              ; If zero, strings are equal
    inc rdi                                ; Move to next character
    inc rsi
    jmp .next_char
.diff:
    mov rax, 1
    ret
.equal:
    xor rax, rax
    ret

; Helper: String length
strlen:
    xor rax, rax
    .next:
    mov al, byte [rdi]
    test al, al
    je .done
    inc rdi
    inc rax
    jmp .next
    .done:
    ret
