# 1차 과제 보고서

## 1. 실습 환경 구축

본 과제는 Windows 환경에서 WSL을 사용하여 진행하였다. 과제 안내에서는 Ubuntu 22.04를 추천하였지만, 현재 사용 중인 Ubuntu 24.04 환경에서 필요한 도구들이 정상적으로 동작하므로 해당 환경을 그대로 사용하였다.

- 실습 환경: WSL Ubuntu 24.04
- 분석 대상: `./handray`
- 사용 도구: `gdb`, `objdump`, `docker`

실습에 필요한 도구는 다음 명령어로 설치하였다.

```bash
sudo apt update
sudo apt install -y build-essential gdb binutils file unzip vim docker.io
```

설치 여부는 다음 명령어로 확인하였다.

```bash
gdb --version
objdump --version
docker --version
```

## 2. 도구 설치

이번 과제에서 사용한 주요 도구의 역할은 다음과 같다.

| 도구 | 역할 |
|---|---|
| gdb | 실행 중인 프로그램을 디버깅하는 도구 |
| objdump | 바이너리 내부의 기계어를 어셈블리로 변환하여 확인하는 도구 |
| docker | 격리된 실습 환경을 구성할 때 사용하는 도구 |

이번 분석에서는 `objdump`를 중심으로 `handray` 바이너리의 함수 구조와 실행 흐름을 확인하였다.

## 3. x86-64 함수 호출 규약

Linux x86-64 환경에서는 일반적으로 System V AMD64 ABI 호출 규약을 따른다. 함수 호출 시 정수형 인자와 포인터 인자는 주로 레지스터를 통해 전달된다.

| 순서 | 레지스터 |
|---|---|
| 1번째 인자 | RDI |
| 2번째 인자 | RSI |
| 3번째 인자 | RDX |
| 4번째 인자 | RCX |
| 5번째 인자 | R8 |
| 6번째 인자 | R9 |

함수의 반환값은 일반적으로 `RAX` 레지스터에 저장된다.

예를 들어 다음 어셈블리 코드는 `write` 함수 호출 전 인자를 세팅하는 부분이다.

```asm
mov    edx,0x2
lea    rax,[rip+0xd90]
mov    rsi,rax
mov    edi,0x1
call   write@plt
```

`write` 함수는 `write(fd, buf, count)` 형태로 호출된다. 호출 규약에 따라 `edi`는 첫 번째 인자, `rsi`는 두 번째 인자, `edx`는 세 번째 인자에 해당한다. 따라서 위 코드는 `write(1, 문자열주소, 2)`로 해석할 수 있다.

`edi`, `edx`는 각각 `rdi`, `rdx`의 하위 32비트 레지스터이다. 따라서 `mov edi, 0x1`은 함수 인자 관점에서 `rdi = 1`로 볼 수 있다.

### caller와 callee

함수를 호출하는 쪽을 caller, 호출당하는 함수를 callee라고 한다. caller는 함수 호출 전에 인자를 정해진 레지스터나 스택에 배치한 뒤 `call` 명령어로 callee를 호출한다. callee는 필요한 지역변수 공간을 스택에 확보하고, 함수 실행 후 `ret` 명령어로 caller에게 돌아간다.

### stack frame 구조

함수는 일반적으로 다음과 같은 프롤로그를 통해 스택 프레임을 구성한다.

```asm
push rbp
mov rbp, rsp
sub rsp, N
```

이는 기존 `rbp` 값을 저장하고, 현재 `rsp`를 기준으로 새 스택 프레임을 만들며, 지역변수 공간을 확보하는 과정이다.

일반적인 스택 프레임 구조는 다음과 같이 볼 수 있다.

```text
높은 주소
+------------------+
| Return Address   |
+------------------+
| Saved RBP        |
+------------------+
| Local Variables  |
+------------------+
낮은 주소
```

## 4. x86-64 Assembly 정리

분석에 사용한 주요 레지스터는 다음과 같다.

| 레지스터 | 역할 |
|---|---|
| RAX | 반환값 저장, 임시 계산 |
| RDI | 1번째 함수 인자 |
| RSI | 2번째 함수 인자 |
| RDX | 3번째 함수 인자 |
| RCX | 4번째 함수 인자 |
| RSP | 스택 포인터 |
| RBP | 스택 프레임 기준 포인터 |
| RIP | 다음 실행 명령어 주소 |
| R8 | 5번째 함수 인자 |
| R9 | 6번째 함수 인자 |

분석 중 자주 사용된 명령어는 다음과 같다.

| 명령어 | 의미 |
|---|---|
| `mov dst, src` | src 값을 dst로 복사 |
| `lea dst, [addr]` | 메모리 값을 읽지 않고 주소값을 계산하여 dst에 저장 |
| `cmp a, b` | a와 b를 비교 |
| `je addr` | 비교 결과가 같으면 점프 |
| `jne addr` | 비교 결과가 다르면 점프 |
| `jg addr` | 비교 결과가 크면 점프 |
| `jmp addr` | 무조건 점프 |
| `call addr` | 함수 호출 |
| `ret` | 함수 반환 |

또한 메모리 접근 크기를 나타내는 표기도 사용되었다.

| 표기 | 크기 |
|---|---|
| `BYTE PTR` | 1바이트 |
| `WORD PTR` | 2바이트 |
| `DWORD PTR` | 4바이트 |
| `QWORD PTR` | 8바이트 |

예를 들어 `DWORD PTR [rbp-0x4]`는 `rbp-0x4` 위치의 메모리를 4바이트 값으로 취급한다는 뜻이다.

## 5. 바이너리 분석 및 복원

### 5.1 분석 대상 확인

먼저 `file` 명령어로 분석 대상 파일의 형식을 확인하였다.

```bash
file ./handray
```

`handray`는 x86-64 Linux ELF 실행 파일이다.

그다음 실행 권한을 부여하고 직접 실행하여 동작을 확인하였다.

```bash
chmod +x ./handray
./handray
```

실행 결과 `> ` 프롬프트가 출력되고, 사용자 입력에 따라 다른 동작을 수행하는 프로그램임을 확인하였다.

### 5.2 문자열 확인

바이너리 내부 문자열은 다음 명령어로 확인하였다.

```bash
strings -tx ./handray
```

확인된 주요 문자열은 다음과 같다.

```text
> 
Hello World!
NOPE
[*] YOU WIN !
-> %s
no.
```

이를 통해 프로그램 내부에 프롬프트 출력, 성공 메시지, 실패 메시지, 입력 출력용 포맷 문자열이 존재함을 확인하였다.

### 5.3 함수 심볼 확인

다음 명령어로 바이너리 내부 심볼을 확인하였다.

```bash
nm -C ./handray
```

출력 결과 `main`, `print`, `check` 함수 심볼이 남아 있었다.

```text
00000000004011b6 T check
00000000004011fb T print
000000000040126c T main
```

`T`는 text section에 존재하는 코드 심볼을 의미한다. 따라서 `main`, `print`, `check`는 `handray` 바이너리 내부에 직접 정의된 함수로 판단하였다.

반면 `printf`, `puts`, `read`, `write`, `exit` 등은 `U` 타입으로 표시되며, 이는 바이너리 내부에 직접 구현된 함수가 아니라 외부 라이브러리에서 참조하는 함수임을 의미한다.

### 5.4 objdump를 이용한 어셈블리 확인

전체 어셈블리 코드는 다음 명령어로 추출하였다.

```bash
objdump -d -M intel ./handray > handray.asm
```

`objdump`는 바이너리 내부의 기계어를 어셈블리 코드로 변환해 보여주는 도구이다. `-d` 옵션은 실행 가능한 코드 영역을 디스어셈블하고, `-M intel` 옵션은 Intel 문법으로 출력한다.

함수별 분석에는 다음 명령어를 사용하였다.

```bash
objdump -d -M intel --disassemble=main ./handray
objdump -d -M intel --disassemble=print ./handray
objdump -d -M intel --disassemble=check ./handray
```

## 6. main 함수 분석

`main` 함수는 프로그램의 메뉴 입력을 처리하는 함수이다.

초반부에서는 스택 프레임을 생성하고 지역변수 공간을 확보한다.

```asm
push   rbp
mov    rbp,rsp
sub    rsp,0x20
```

이후 다음 코드에서 지역변수 하나를 0으로 초기화한다.

```asm
mov    DWORD PTR [rbp-0x4],0x0
```

`DWORD PTR [rbp-0x4]`는 4바이트 지역변수 위치로 볼 수 있으므로, C 코드에서는 `int input = 0;` 정도로 해석할 수 있다.

### 6.1 프롬프트 출력

다음 코드는 `write` 함수 호출 부분이다.

```asm
mov    edx,0x2
lea    rax,[rip+0xd90]        # 402022
mov    rsi,rax
mov    edi,0x1
call   write@plt
```

`lea rax, [rip+0xd90]`는 `rip` 기준 상대 주소 계산을 통해 문자열 주소를 `rax`에 저장한다. 이때 `rip`는 현재 명령어가 아니라 다음 명령어 주소를 기준으로 계산된다.

계산된 주소 `0x402022`를 확인하면 문자열 `"> "`가 존재한다. 따라서 인자 값은 다음과 같이 해석된다.

| 레지스터 | 값 | 의미 |
|---|---|---|
| RDI | 1 | 표준 출력 |
| RSI | 0x402022 | `"> "` 문자열 주소 |
| RDX | 2 | 출력 바이트 수 |

따라서 C 코드로는 다음과 같다.

```c
write(1, "> ", 2);
```

### 6.2 사용자 입력

프롬프트 출력 이후에는 `read` 함수가 호출된다.

```asm
lea    rax,[rbp-0x4]
mov    edx,0x2
mov    rsi,rax
mov    edi,0x0
call   read@plt
```

`rbp-0x4`는 앞에서 0으로 초기화한 지역변수 위치이다. `lea rax, [rbp-0x4]`는 해당 지역변수의 주소를 `rax`에 저장한다.

호출 규약에 따라 인자를 해석하면 다음과 같다.

| 레지스터 | 값 | 의미 |
|---|---|---|
| RDI | 0 | 표준 입력 |
| RSI | `&input` | 입력 저장 위치 |
| RDX | 2 | 읽을 바이트 수 |

따라서 C 코드로는 다음과 같다.

```c
read(0, &input, 2);
```

### 6.3 입력값 비교

입력 이후에는 입력값의 첫 번째 바이트를 꺼내 비교한다.

```asm
lea    rax,[rbp-0x4]
movzx  eax,BYTE PTR [rax]
movzx  eax,al
```

`BYTE PTR [rax]`는 입력값 중 첫 번째 바이트를 의미한다.

이후 다음과 같이 입력값을 비교한다.

```asm
cmp    eax,0x33
je     ...
cmp    eax,0x31
je     ...
cmp    eax,0x32
je     ...
```

`0x31`, `0x32`, `0x33`은 ASCII 코드로 각각 `'1'`, `'2'`, `'3'`이다.

각 분기에서 호출되는 함수는 다음과 같다.

| 입력 | 실행 흐름 |
|---|---|
| `'1'` | `print()` 호출 |
| `'2'` | `puts("Hello World!")` 호출 |
| `'3'` | `check()` 호출 |

마지막에는 다시 프롬프트 출력 주소로 점프한다.

```asm
jmp    401286
```

이는 위쪽 주소로 다시 이동하는 구조이므로 무한 반복문으로 해석할 수 있다.

따라서 `main` 함수는 다음과 같이 복원할 수 있다.

```c
int main(int argc, char **argv) {
    int input = 0;

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

    return 0;
}
```

## 7. print 함수 분석

`print` 함수는 사용자 입력을 받아 다시 출력하는 함수이다.

초반부에서 스택 프레임을 생성하고 0x20 크기의 지역변수 공간을 확보한다.

```asm
push   rbp
mov    rbp,rsp
sub    rsp,0x20
```

이후 `[rbp-0x20]` 부근의 메모리를 0으로 초기화하는 코드가 존재한다. 이는 지역 버퍼를 초기화하는 동작으로 해석할 수 있다.

중요한 입력 부분은 다음과 같다.

```asm
lea    rax,[rbp-0x20]
mov    edx,0x17
mov    rsi,rax
mov    edi,0x0
call   read@plt
```

`0x17`은 10진수로 23이다. 호출 규약에 따라 해석하면 다음과 같다.

```c
read(0, buf, 23);
```

여기서 `buf`는 `[rbp-0x20]` 위치의 지역 버퍼이다.

`read` 호출 이후 반환값은 `eax`에 저장되며, 이 값은 지역변수에 저장된 뒤 0과 비교된다.

```asm
cmp    DWORD PTR [rbp-0x4],0x0
```

`read`의 반환값이 0이면 `"no."`를 출력하고, 0이 아니면 입력받은 버퍼를 출력한다.

출력 부분은 `printf` 호출로 이루어진다.

```asm
lea    rax,[rbp-0x20]
mov    rsi,rax
lea    rax,[rip+...]
mov    rdi,rax
mov    eax,0x0
call   printf@plt
```

`rdi`는 포맷 문자열 주소, `rsi`는 버퍼 주소이다. 포맷 문자열은 `"-> %s"` 형태이다.

따라서 `print` 함수는 다음과 같이 복원할 수 있다.

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

## 8. check 함수 분석

`check` 함수는 특정 값과 `0xdeadbeef`를 비교하여 성공 또는 실패 메시지를 출력하는 함수이다.

함수 초반부에서는 다른 함수와 마찬가지로 스택 프레임을 생성한다.

```asm
push   rbp
mov    rbp,rsp
sub    rsp,0x20
```

핵심 비교 부분은 다음과 같다.

```asm
mov    rax,QWORD PTR [rbp-0x20]
mov    edx,0xdeadbeef
cmp    rax,rdx
jne    ...
```

`QWORD PTR [rbp-0x20]`는 `[rbp-0x20]` 위치의 8바이트 값을 의미한다. 이 값을 `rax`에 저장한 뒤, `0xdeadbeef`와 비교한다.

비교 결과가 같으면 성공 분기로 진행한다.

```asm
lea    rax,[rip+...]
mov    rdi,rax
call   puts@plt

mov    edi,0x1
call   exit@plt
```

해당 문자열은 `"[*] YOU WIN !"`이며, 이후 `exit(1)`을 호출한다.

비교 결과가 다르면 실패 분기로 이동하여 `"NOPE"`를 출력한다.

따라서 `check` 함수는 다음과 같이 복원할 수 있다.

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

여기서 중요한 점은 `value`에 해당하는 `[rbp-0x20]` 값이 `check` 함수 내부에서 초기화되지 않는다는 것이다. 즉, `check` 함수는 초기화되지 않은 지역변수 값을 `0xdeadbeef`와 비교하는 구조이다.

## 9. 복원한 C 코드

최종적으로 `handray` 바이너리는 다음과 같은 C 코드로 복원할 수 있다.

```c
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

void check(void) {
    unsigned long value;

    if (value == 0xdeadbeef) {
        puts("[*] YOU WIN !");
        exit(1);
    }

    puts("NOPE");
}

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

int main(int argc, char **argv) {
    int input = 0;

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

    return 0;
}
```

## 10. 결론

`handray` 바이너리는 사용자 입력에 따라 `print`, `check` 등의 내부 함수를 호출하는 메뉴형 프로그램이다. `main` 함수는 `> ` 프롬프트를 출력하고 2바이트 입력을 받은 뒤, 입력값의 첫 번째 바이트에 따라 분기한다.

`print` 함수는 사용자 입력을 스택의 지역 버퍼에 저장한 뒤 출력한다. `check` 함수는 스택의 `[rbp-0x20]` 위치에 있는 8바이트 값을 `0xdeadbeef`와 비교하여, 같으면 `"[*] YOU WIN !"`을 출력하고 다르면 `"NOPE"`를 출력한다.

분석 결과 `check` 함수에서 비교에 사용되는 값이 함수 내부에서 초기화되지 않는다는 점을 확인하였다.
