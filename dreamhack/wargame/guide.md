# Dreamhack Wargame Guide

## 기본 워크플로우

1. 문제 폴더 생성
- mkdir chall_xxxx
- cd chall_xxxx
2. template 복사 → notes.md
- cp ../../template/notes.md notes.md
3. solve.py 작성
- touch solve.py
4. 실행 및 디버깅
- code .
5. notes 정리
6. git commit & push

---

# notes 작성 팁

## 반드시 포함할 것
1. 왜 이 방법을 사용했는가
2. 문제의 핵심 구조
3. 다음 문제에 적용 가능한 포인트

## 좋은 예
- recvline을 사용한 이유: 버퍼 꼬임 방지
- split을 사용한 이유: 간단한 문자열 파싱

## 나쁜 예
- 그냥 풀었다 ❌

## pwntools 기본 패턴

- recvline(): 한 줄 받기
- recvuntil(): 특정 문자열까지 받기
- sendline(): 입력 전송

---

## 문자열 처리

- split(): 간단한 파싱
- strip(): 공백 제거

---

## 중요한 습관

- 문제마다 notes 작성
- 왜 이렇게 풀었는지 기록
- 재사용 가능한 코드 구조 만들기

---

## 실수 방지

- bytes vs string 구분 (b"...")
- 버퍼 꼬임 방지 (recvline 사용)
- 출력 형식 정확히 확인