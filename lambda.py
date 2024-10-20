import sqlite3

db_path = "/mnt/efs/sqlite3.db"

conn = sqlite3.connect(db_path)

cur = conn.cursor()
cur.execute("""CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, name TEXT)""")
cur.execute("INSERT INTO users (name) VALUES ('John Doe')")

conn.commit()

cur.execute("SELECT * FROM users")
print(cur.fetchall())

conn.close()
