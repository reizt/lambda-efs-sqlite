from iservices import IServices
from iservices.post_repo import IPostRepo
from iservices.user_repo import IUserRepo
from services.post_repo import PostRepo
from services.user_repo import UserRepo


class Services(IServices):
  user_repo: IUserRepo
  post_repo: IPostRepo

  def __init__(self) -> None:
    self.user_repo = UserRepo()
    self.post_repo = PostRepo()
