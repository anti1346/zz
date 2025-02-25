import mysql.connector

# MySQL 접속 정보
DB_CONFIG = {
    "user": "zabbix",
    "password": "비밀번호",
    "host": "localhost",
    "database": "zabbix",
}

# MySQL에서 IP와 호스트명 조회
def fetch_server_list():
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        cursor = conn.cursor()

        query = """
        SELECT CONCAT(i.ip, ' ', h.host)
        FROM hosts h
        JOIN interface i ON h.hostid = i.hostid
        WHERE h.status = 0 AND i.type = 1;
        """
        cursor.execute(query)

        # 결과를 배열로 저장
        server_list = [f'"{row[0]}"' for row in cursor.fetchall()]

        # 배열 출력
        print("server_list=(")
        for entry in server_list:
            print(f"    {entry}")
        print(")")

    except mysql.connector.Error as err:
        print(f"Error: {err}")
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()

if __name__ == "__main__":
    fetch_server_list()

