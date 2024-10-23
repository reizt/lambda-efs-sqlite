import os

from peewee import CharField, ForeignKeyField, IntegerField, Model, SqliteDatabase

from entities.post import Post
from entities.user import User
from iservices.post_repo import RepoPost
from iservices.user_repo import RepoUser

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

  def to_interface(self) -> RepoUser:
    return RepoUser(
      id=self.id,
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

  def to_interface(self) -> RepoPost:
    user: PeeweeUser = self.user
    return RepoPost(
      id=int(self.id),
      user_id=int(user.id),
      title=self.title,
      content=self.content,
    )
