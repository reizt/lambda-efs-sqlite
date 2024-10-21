import os

from peewee import CharField, ForeignKeyField, IntegerField, Model, SqliteDatabase

from ent import Post, User

database_url = os.environ["DATABASE_URL"]
db = SqliteDatabase(database_url)


class PeeweeUser(Model):
  id = IntegerField(primary_key=True)
  name = CharField()

  class Meta:
    database = db
    db_table = "users"

  def to_ent(self) -> User:
    return User(
      id=int(self.id),
      name=self.name,
    )


class PeeweePost(Model):
  id = IntegerField(primary_key=True)
  title = CharField()
  content = CharField()
  user = ForeignKeyField(PeeweeUser, to_field=PeeweeUser.id)

  class Meta:
    database = db
    db_table = "posts"

  def to_ent(self) -> Post:
    user: PeeweeUser = self.user
    return Post(
      id=int(self.id),
      user_id=int(user.id),
      title=self.title,
      content=self.content,
    )


class Repo:
  def __init__(self) -> None:
    db.create_tables([PeeweeUser, PeeweePost])

  def create_user(self, name: str) -> User:
    user: PeeweeUser = PeeweeUser.create(
      name=name,
    )
    return user.to_ent()

  def get_users(self) -> list[User]:
    users: list[PeeweeUser] = PeeweeUser.select()
    return [x.to_ent() for x in users]

  def get_user_by_id(self, id: int) -> User:
    user: PeeweeUser = PeeweeUser.get(PeeweeUser.id == id)
    return user.to_ent()

  def create_post(self, title: str, content: str, user_id: int) -> Post:
    user: PeeweeUser = PeeweeUser.get(PeeweeUser.id == user_id)
    post: PeeweePost = PeeweePost.create(
      title=title,
      content=content,
      user=user,
    )
    return post.to_ent()

  def get_posts(self) -> list[Post]:
    posts: list[PeeweePost] = PeeweePost.select()
    return [x.to_ent() for x in posts]

  def get_post_by_id(self, id: int) -> Post:
    post: PeeweePost = PeeweePost.get(PeeweePost.id == id)
    return post.to_ent()
