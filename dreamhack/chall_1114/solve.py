from pwn import *

p = remote("host3.dreamhack.games", 23305)

for i in range(50):
    first = int(p.recvuntil(b'+',drop=True))
    second = int(p.recvuntil(b'=?\n',drop=True))

    p.sendline(str(first+second).encode())

print(p.recvall().decode())

