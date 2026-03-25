## 1. 문제 요약
입력한 쉘코드를 실행하는 서비스에서 execve 계열 syscall이 막혀 있으므로,
주어진 flag 파일 경로를 직접 open-read-write 방식으로 읽어야 하는 문제

## 2. 핵심 개념
- shellcode
- ORW(open-read-write)
- shellcraft
- syscall 제한 우회

## 3. 문제 분석
문제에서 execve, execveat가 제한되어 있어 쉘 획득 방식은 사용할 수 없다.
대신 flag 파일의 절대 경로가 주어지므로, 해당 파일을 직접 열고 읽어서 출력하는 ORW 방식이 정답이다.

## 4. 풀이 전략
- shellcraft.open()으로 flag 파일 열기
- shellcraft.read()로 파일 내용 읽기
- shellcraft.write()로 stdout에 출력
- 응답 데이터에서 DH{...} 형식의 플래그만 추출

## 5. 배운 점
- execve가 막혀 있으면 쉘 실행 대신 ORW 방식으로 접근해야 한다
- shellcraft를 사용하면 syscall 기반 shellcode를 빠르게 만들 수 있다
- 서버 응답은 항상 문자열만 오는 것이 아니므로 decode 에러를 주의해야 한다