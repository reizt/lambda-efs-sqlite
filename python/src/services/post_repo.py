from iservices.post_repo import IPostRepo, RepoPost

from .schema import PeeweePost, PeeweeUser, db


class PostRepo(IPostRepo):
  def __init__(self) -> None:
    db.create_tables([PeeweePost])

  async def list(self) -> list[RepoPost]:
    posts: list[PeeweePost] = PeeweePost.select()
    return [x.to_interface() for x in posts]

  async def pick(self, where: IPostRepo.Where) -> RepoPost:
    post: PeeweePost = PeeweePost.get(PeeweePost.id == where.id)
    return post.to_interface()

  async def create(self, data: IPostRepo.CreateData) -> None:
    user: PeeweeUser = PeeweeUser.get(PeeweeUser.id == data.user_id)
    PeeweePost.create(
      title=data.title,
      content=data.content,
      user=user,
    )

  async def update(self, where: IPostRepo.Where, data: IPostRepo.UpdateData) -> None:
    post: PeeweePost = PeeweePost.get(PeeweePost.id == where.id)
    post.title = data.title
    post.content = data.content
    post.save()

  async def delete(self, where: IPostRepo.Where) -> None:
    post: PeeweePost = PeeweePost.get(PeeweePost.id == where.id)
    post.delete_instance()
