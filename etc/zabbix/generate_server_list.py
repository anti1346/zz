import mysql.connector

# MySQL 접속 정보
DB_CONFIG = {
    "user": "zabbix",
    "password": "비밀번호",
    "host": "localhost",
    "database": "zabbix",
}

# MySQL에서 호스트명과 IP 조회
def fetch_server_list():
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

        # 결과를 (호스트 이름, IP 주소) 튜플로 변환하여 리스트에 저장
        server_list = [(row[0], row[1]) for row in cursor.fetchall()]

        # 리스트 출력
        print("server_list = [")
        for host, ip in server_list:
            print(f'    ("{host}", "{ip}"),')
        print("]")

    except mysql.connector.Error as err:
        print(f"Error: {err}")
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()

if __name__ == "__main__":
    fetch_server_list()
