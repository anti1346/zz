import mysql.connector

# MySQL 접속 정보
DB_CONFIG = {
    "user": "zabbix",
    "password": "비밀번호",
    "host": "localhost",
    "database": "zabbix",
}

# 서버 목록을 저장할 파일 경로
OUTPUT_FILE = "server_list.txt"

def fetch_server_list():
    """MySQL에서 서버 목록을 조회하고 파일로 저장"""
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        cursor = conn.cursor()

        query = """
        SELECT h.host, i.ip
        FROM hosts h
        JOIN interface i ON h.hostid = i.hostid
        WHERE h.status = 0 AND i.type = 1;
        """
        cursor.execute(query)

        # 결과를 파일로 저장
        with open(OUTPUT_FILE, "w") as file:
            for hostname, ip in cursor.fetchall():
                file.write(f"{hostname} {ip}\n")

        print(f"[INFO] 서버 목록이 {OUTPUT_FILE} 파일에 저장되었습니다.")

    except mysql.connector.Error as err:
        print(f"[ERROR] MySQL 연결 오류: {err}")

    finally:
        if 'conn' in locals() and conn.is_connected():
            cursor.close()
            conn.close()

if __name__ == "__main__":
    fetch_server_list()
