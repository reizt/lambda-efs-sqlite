from typing import TypedDict

from fastapi import APIRouter, HTTPException, Response

from iservices import IServices
from iusecases.create_post import Input
from usecases.create_post import create_usecase


def create_router(services: IServices) -> APIRouter:
  usecase = create_usecase(services)
  router = APIRouter()

  class RequestJson(TypedDict):
    user_id: int
    title: str
    content: str

  @router.post("/posts")
  async def handle(body: RequestJson) -> Response:
    input = Input(
      user_id=body["user_id"],
      title=body["title"],
      content=body["content"],
    )
    try:
      await usecase.run(input)
    except Exception:
      raise HTTPException(400, "Bad Request")

    return Response()

  return router
