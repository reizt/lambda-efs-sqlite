from iservices.user_repo import IUserRepo, RepoUser

from .schema import PeeweeUser, db


class UserRepo(IUserRepo):
  def __init__(self) -> None:
    db.create_tables([PeeweeUser])

  async def list(self) -> list[RepoUser]:
    users: list[PeeweeUser] = PeeweeUser.select()
    return [x.to_interface() for x in users]

  async def pick(self, where: IUserRepo.Where) -> RepoUser | None:
    user: PeeweeUser | None = PeeweeUser.get(PeeweeUser.id == where.id)
    if user is None:
      return None
    return user.to_interface()

  async def create(self, data: IUserRepo.CreateData) -> RepoUser:
    user: PeeweeUser = PeeweeUser.create(
      name=data.name,
    )
    return user.to_interface()

  async def update(self, where: IUserRepo.Where, data: IUserRepo.UpdateData) -> None:
    user: PeeweeUser | None = PeeweeUser.get(PeeweeUser.id == where.id)
    if user is None:
      raise Exception("User not found")
    user.name = data.name
    user.save()

  async def delete(self, where: IUserRepo.Where) -> None:
    user: PeeweeUser | None = PeeweeUser.get(PeeweeUser.id == where.id)
    if user is None:
      raise Exception("User not found")
    user.delete_instance()
