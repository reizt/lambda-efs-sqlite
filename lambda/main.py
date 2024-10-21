import sqlite3

db_path = "/mnt/efs/sqlite3.db"


def handler(event, context):
  print(event)
  try:
    conn = sqlite3.connect(db_path)
    print("connected")

    cur = conn.cursor()
    print("cursor")

    cur.execute(
      """CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, name TEXT)"""
    )
    print("table created")

    cur.execute("INSERT INTO users (name) VALUES ('John Doe')")
    print("inserted")

    conn.commit()
    print("committed")

    cur.execute("SELECT * FROM users")
    rows = cur.fetchall()
    print("fetched")
    print(rows)
  finally:
    conn.close()
