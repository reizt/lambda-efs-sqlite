from typing import TypedDict

from fastapi import APIRouter, HTTPException, Response

from iservices import IServices
from iusecases.create_user import Input
from usecases.create_user import create_usecase


def create_router(services: IServices) -> APIRouter:
  usecase = create_usecase(services)
  router = APIRouter()

  class RequestJson(TypedDict):
    name: str

  @router.post("/users")
  async def handle(body: RequestJson) -> Response:
    input = Input(name=body["name"])
    try:
      await usecase.run(input)
    except Exception:
      raise HTTPException(400, "Bad Request")

    return Response()

  return router
