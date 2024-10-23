from pydantic import BaseModel


class Input(BaseModel):
  user_id: int
  title: str
  content: str


class Output(BaseModel):
  pass
