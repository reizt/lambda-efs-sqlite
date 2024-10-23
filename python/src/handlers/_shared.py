from typing import TypedDict


class UserJson(TypedDict):
  id: int
  name: str


class PostJson(TypedDict):
  id: int
  user_id: int
  title: str
  content: str
