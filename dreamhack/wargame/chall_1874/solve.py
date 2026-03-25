from pwn import *

p = remote("host3.dreamhack.games", 9274)

p.recvuntil(b"There are 50 rounds.\n")

for _ in range(50):

    p.recvline()
    flag_index = 0

    for _ in range(10):
        line = p.recvline().decode().strip()
        idx, item = line.split(". ",1)
        if item == "flag":
            flag_index=int(idx)
            break

    p.sendlineafter(b"> ",str(flag_index).encode())

print(p.recvall().decode())


