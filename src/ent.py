from typing import TypedDict


class User(TypedDict):
  id: int
  name: str


class Post(TypedDict):
  id: int
  user_id: int
  title: str
  content: str
