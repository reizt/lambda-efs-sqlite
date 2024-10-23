from abc import ABC, abstractmethod
from dataclasses import dataclass

from entities.user import User


@dataclass
class RepoUser:
  id: int
  name: str

  def to_entity(self) -> User:
    return User(
      id=self.id,
      name=self.name,
    )


class IUserRepo(ABC):
  @dataclass
  class Where:
    id: int

  @abstractmethod
  async def list(self) -> list[RepoUser]:
    pass

  @abstractmethod
  async def pick(self, where: Where) -> RepoUser:
    pass

  @dataclass
  class CreateData:
    name: str

  @abstractmethod
  async def create(self, data: CreateData) -> None:
    pass

  @dataclass
  class UpdateData:
    name: str

  @abstractmethod
  async def update(self, where: Where, data: UpdateData) -> None:
    pass

  @abstractmethod
  async def delete(self, where: Where) -> None:
    pass
