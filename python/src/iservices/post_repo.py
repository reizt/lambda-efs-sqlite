from abc import ABC, abstractmethod
from dataclasses import dataclass

from entities.post import Post


@dataclass
class RepoPost:
  id: int
  user_id: int
  title: str
  content: str

  def to_entity(self) -> Post:
    return Post(
      id=self.id,
      user_id=self.user_id,
      title=self.title,
      content=self.content,
    )


class IPostRepo(ABC):
  @dataclass
  class Where:
    id: int

  @abstractmethod
  async def list(self) -> list[RepoPost]:
    pass

  @abstractmethod
  async def pick(self, where: Where) -> RepoPost | None:
    pass

  @dataclass
  class CreateData:
    user_id: int
    title: str
    content: str

  @abstractmethod
  async def create(self, data: CreateData) -> RepoPost:
    pass

  @dataclass
  class UpdateData:
    title: str
    content: str

  @abstractmethod
  async def update(self, where: Where, data: UpdateData) -> None:
    pass

  @abstractmethod
  async def delete(self, where: Where) -> None:
    pass
