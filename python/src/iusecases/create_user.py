from pydantic import BaseModel

from entities.user import User


class Input(BaseModel):
  name: str


class Output(BaseModel):
  user: User
