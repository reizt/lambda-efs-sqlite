import os
import sqlite3


def handler(event, context):
  print(event)
  efs_dir = os.environ["EFS_MOUNT_PATH"]
  print(os.listdir(efs_dir))
  conn = sqlite3.connect(f"{efs_dir}/sqlite3.db")
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
