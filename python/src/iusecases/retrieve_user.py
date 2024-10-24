from pydantic import BaseModel

from entities.user import User


class Input(BaseModel):
  user_id: int


class Output(BaseModel):
  user: User | None
