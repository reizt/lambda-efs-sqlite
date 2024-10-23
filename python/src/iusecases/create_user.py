from pydantic import BaseModel


class Input(BaseModel):
  name: str


class Output(BaseModel):
  pass
