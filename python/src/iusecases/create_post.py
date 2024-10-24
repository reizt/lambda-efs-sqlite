from pydantic import BaseModel

from entities.post import Post


class Input(BaseModel):
  user_id: int
  title: str
  content: str


class Output(BaseModel):
  post: Post
