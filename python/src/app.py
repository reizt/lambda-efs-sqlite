import os
from typing import Any

from fastapi import FastAPI

from handlers import create_post, create_user, get_posts, get_users
from services import Services


def create_app() -> FastAPI:
  app = FastAPI(root_path=os.environ["API_ROOT_PATH"])

  services = Services()

  @app.get("/")
  def read_root() -> dict[str, Any]:
    return {"Hello": "World"}

  app.include_router(get_users.create_router(services))
  app.include_router(create_user.create_router(services))
  app.include_router(get_posts.create_router(services))
  app.include_router(create_post.create_router(services))

  return app
