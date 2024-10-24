from pydantic import BaseModel

from entities.user import User


class Input(BaseModel):
  pass


class Output(BaseModel):
  users: list[User]
