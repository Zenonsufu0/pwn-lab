from flask import Flask, render_template, request, redirect, url_for
import sqlite3
import os

app = Flask(__name__)
DB_PATH = "users.db"


def get_conn():
    # SQLite 데이터베이스 연결
    return sqlite3.connect(DB_PATH)


def init_db():
    # DB 파일이 이미 있으면 다시 만들지 않음
    if os.path.exists(DB_PATH):
        return

    conn = get_conn()
    cur = conn.cursor()

    # 사용자 테이블 생성
    cur.execute("""
        CREATE TABLE users (
            id TEXT PRIMARY KEY,
            pw TEXT NOT NULL
        )
    """)

    # 관리자 계정 추가
    cur.execute("INSERT INTO users (id, pw) VALUES (?, ?)", ("admin", "admin"))

    conn.commit()
    conn.close()


@app.route("/")
def index():
    # 기본 주소 접속 시 로그인 페이지로 이동
    return redirect(url_for("login"))


@app.route("/login", methods=["GET", "POST"])
def login():
    message = ""

    if request.method == "POST":
        # 사용자가 입력한 아이디/비밀번호 받기
        user_id = request.form.get("id", "")
        user_pw = request.form.get("pw", "")

        conn = get_conn()
        cur = conn.cursor()

        # 취약한 쿼리
        # 사용자 입력을 문자열에 직접 이어붙여 SQL Injection 가능
        query = f"SELECT * FROM users WHERE id='{user_id}' AND pw='{user_pw}'"
        print("[VULN QUERY]", query)

        try:
            cur.execute(query)
            row = cur.fetchone()

            if row:
                message = f"[로그인 성공] {row[0]} 님 환영합니다."
            else:
                message = "[로그인 실패] 아이디 또는 비밀번호가 틀렸습니다."
        except Exception as e:
            message = f"[로그인 에러] {e}"

        conn.close()

    return render_template(
        "login.html",
        title="취약한 로그인",
        action_url="/login",
        message=message
    )


if __name__ == "__main__":
    # 프로그램 시작 시 DB 초기화
    init_db()

    # 로컬 환경에서만 실행
    app.run(host="127.0.0.1", port=5000, debug=True)