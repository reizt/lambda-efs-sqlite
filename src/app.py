import os
import sqlite3
from typing import Any

from fastapi import FastAPI

app = FastAPI()


@app.get("/hello")
def read_root() -> dict[str, str]:
  return {"Hello": "World"}


@app.post("/db")
def db(event: dict[str, Any], ctx: dict[str, Any]) -> None:
  print(event)
  efs_dir = os.environ["EFS_MOUNT_PATH"]
  print("efs_dir", efs_dir)
  print("exists: ", os.path.isdir(efs_dir))
  print("read permission: ", os.access(efs_dir, os.R_OK))
  print("write permission: ", os.access(efs_dir, os.W_OK))
  print("listdir: ", os.listdir(efs_dir))
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
