# pwn-lab

보안 공부 기록 저장소입니다. 드림핵 워게임 풀이, SecurityFact 스터디 과제, CyberDefenders CTF, 웹해킹 실습 환경을 포함합니다.

---

## 폴더 구조

```
pwn-lab/
├── .gitignore
├── README.md
├── dreamhack/
│   ├── template/           # 공용 템플릿 (exploit.py, notes.md)
│   └── wargame/            # 문제별 풀이 폴더
│       ├── guide.md        # 풀이 워크플로우 가이드
│       ├── chall_410/
│       ├── chall_1874/
│       └── chall_1114/
│
├── SecurityFact/           # SecurityFact 스터디 과제
│   ├── Assembly/           # 어셈블리 실습 (NASM)
│   └── Study/
│       ├── Task_1st/       # handray 바이너리 리버싱 + 보고서
│       └── Task_2nd/       # handray pwntools exploit + 보고서
│
├── CyberDefenders/         # CyberDefenders CTF
│   └── Reveal/             # 메모리 포렌식 (Volatility3)
│       ├── notes/          # 분석 노트 및 타임라인
│       ├── output/         # volatility 플러그인 실행 결과
│       ├── report/         # 보고서 초안
│       └── scripts/        # 자동화 스크립트
│
└── web/                    # 웹해킹 실습 환경 (Flask)
```

---

## 플랫폼별 설명

### dreamhack
드림핵 워게임 문제 풀이를 관리합니다.

- 새 문제는 `wargame/chall_XXXX/` 형태로 폴더를 만들어 진행합니다.
- 각 폴더에는 `notes.md` (분석 기록)와 `solve.py` (익스플로잇 코드)가 들어갑니다.
- 풀이 워크플로우는 [`wargame/guide.md`](dreamhack/wargame/guide.md)를 참고하세요.
- 익스플로잇 템플릿은 [`template/exploit.py`](dreamhack/template/exploit.py)를 복사해서 사용합니다.

**풀이 목록**

| 번호 | 풀이 | 기술 |
|---|---|---|
| chall_410 | [풀이](dreamhack/wargame/chall_410/solve.py) | - |
| chall_1874 | [풀이](dreamhack/wargame/chall_1874/solve.py) | - |
| chall_1114 | [풀이](dreamhack/wargame/chall_1114/solve.py) | - |

---

### SecurityFact
SecurityFact 스터디 과제 코드 및 보고서를 관리합니다.

| 과제 | 내용 | 보고서 |
|---|---|---|
| Task_1st | handray 바이너리 리버싱 (어셈블리 분석) | [보고서](SecurityFact/Study/Task_1st/Task1_handray_report_.md) |
| Task_2nd | handray pwntools exploit (스택 재사용 취약점) | [보고서](SecurityFact/Study/Task_2nd/Task2_handray_pwn_report.md) |

---

### CyberDefenders — Reveal
Windows 메모리 덤프 포렌식 챌린지입니다. Volatility3를 사용하여 프로세스, 네트워크, 악성코드 흔적을 분석합니다.

```bash
# 환경 세팅
cd CyberDefenders/Reveal
python3 -m venv .venv && source .venv/bin/activate
pip install volatility3

# 분석 실행
bash scripts/commands.sh
```

---

### web
Flask 기반 웹 취약점 실습 환경입니다.

```bash
cd web
source .venv/bin/activate
python3 app.py
```

---

## 환경

| 항목 | 내용 |
|---|---|
| OS | Ubuntu (WSL2) |
| Python | 3.12 |
| 주요 도구 | pwntools, pwndbg, Volatility3, GDB, NASM |
