from fastapi import FastAPI
from pydantic import BaseModel

from src.ent import Post, User
from src.repo import Repo

app = FastAPI()


@app.get("/hello")
def root() -> dict[str, str]:
  return {"Hello": "World"}


repo = Repo()


class CreateUser(BaseModel):
  name: str


@app.post("/users")
def create_user(body: CreateUser) -> User:
  return repo.create_user(body.name)


@app.get("/users")
def get_users() -> list[User]:
  return repo.get_users()


@app.get("/users/{id}")
def get_user(id: int) -> User:
  return repo.get_user_by_id(id)


class CreatePost(BaseModel):
  title: str
  content: str
  user_id: int


@app.post("/posts")
def create_post(body: CreatePost) -> Post:
  return repo.create_post(body.title, body.content, body.user_id)


@app.get("/posts")
def get_posts() -> list[Post]:
  return repo.get_posts()


@app.get("/posts/{id}")
def get_post(id: int) -> Post:
  return repo.get_post_by_id(id)
