section .bss
    buffer resb 100     ; 입력받은 문자열을 저장할 버퍼 100바이트 확보

section .text
    global _start

_start:
    mov rax, 0          ; syscall 번호 0 = read
    mov rdi, 0          ; 파일 디스크립터 0 = stdin(키보드 입력)
    mov rsi, buffer     ; 입력 데이터를 저장할 버퍼 주소
    mov rdx, 100        ; 최대 100바이트까지 읽음
    syscall             ; read(0, buffer, 100)

    mov rdx, rax        ; read의 반환값(실제로 읽은 바이트 수)을 rdx에 저장
    mov rax, 1          ; syscall 번호 1 = write
    mov rdi, 1          ; 파일 디스크립터 1 = stdout(화면 출력)
    mov rsi, buffer     ; 출력할 데이터는 buffer에 있음
    syscall             ; write(1, buffer, 읽은 바이트 수)

    mov rax, 60         ; syscall 번호 60 = exit
    xor rdi, rdi        ; 종료 코드 0
    syscall             ; exit(0)