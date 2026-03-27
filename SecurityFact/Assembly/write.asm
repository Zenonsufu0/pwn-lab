main:
    push rbp                    ; 이전 함수의 베이스 포인터 저장
    mov rbp, rsp                ; 현재 함수의 스택 프레임 설정

    mov esi, 0x20               ; esi = 0x20(32), 출력할 바이트 수
    mov rdi, 0x401800           ; rdi = 0x401800, 출력할 문자열 시작 주소

    call write_n                ; write_n 함수 호출

    mov eax, 0x0                ; main의 반환값 0 설정
    pop rbp                     ; 저장해둔 이전 rbp 복원
    ret                         ; main 종료


write_n:
    push rbp                    ; 이전 함수의 베이스 포인터 저장
    mov rbp, rsp                ; 현재 함수의 스택 프레임 설정

    mov QWORD PTR [rbp-0x8], rdi ; 첫 번째 인자 rdi(문자열 주소)를 [rbp-0x8]에 저장
    mov DWORD PTR [rbp-0xc], esi ; 두 번째 인자 esi(길이)를 [rbp-0xc]에 저장

    xor rdx, rdx                ; rdx를 0으로 초기화
    mov edx, DWORD PTR [rbp-0xc] ; edx = 출력할 길이
    mov rsi, QWORD PTR [rbp-0x8] ; rsi = 출력할 문자열 주소
    mov rdi, 0x1                ; rdi = 1, stdout(화면 출력)
    mov rax, 0x1                ; rax = 1, syscall 번호 write
    syscall                     ; write(1, 문자열주소, 길이) 실행

    pop rbp                     ; 저장해둔 이전 rbp 복원
    ret                         ; write_n 함수 종료