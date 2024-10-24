from iservices.post_repo import IPostRepo, RepoPost

from .schema import PeeweePost, PeeweeUser, db


class PostRepo(IPostRepo):
  def __init__(self) -> None:
    db.create_tables([PeeweePost])

  async def list(self) -> list[RepoPost]:
    posts: list[PeeweePost] = PeeweePost.select()
    return [x.to_interface() for x in posts]

  async def pick(self, where: IPostRepo.Where) -> RepoPost | None:
    post: PeeweePost | None = PeeweePost.get(PeeweePost.id == where.id)
    if post is None:
      return None
    return post.to_interface()

  async def create(self, data: IPostRepo.CreateData) -> RepoPost:
    user: PeeweeUser | None = PeeweeUser.get(PeeweeUser.id == data.user_id)
    if user is None:
      raise Exception("User not found")
    post: PeeweePost = PeeweePost.create(
      title=data.title,
      content=data.content,
      user=user,
    )
    return post.to_interface()

  async def update(self, where: IPostRepo.Where, data: IPostRepo.UpdateData) -> None:
    post: PeeweePost | None = PeeweePost.get(PeeweePost.id == where.id)
    if post is None:
      raise Exception("Post not found")
    post.title = data.title
    post.content = data.content
    post.save()

  async def delete(self, where: IPostRepo.Where) -> None:
    post: PeeweePost | None = PeeweePost.get(PeeweePost.id == where.id)
    if post is None:
      raise Exception("Post not found")
    post.delete_instance()
