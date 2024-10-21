import os
import sqlite3


def handler(event, context):
  print(event)
  db_path = os.environ["DATABASE_PATH"]
  conn = sqlite3.connect(db_path)
  try:
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


if __name__ == "__main__":
  handler({}, {})
