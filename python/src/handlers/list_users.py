from typing import TypedDict

from fastapi import APIRouter, HTTPException, Response
from fastapi.responses import JSONResponse

from handlers._shared import UserJson
from iservices import IServices
from iusecases.list_users import Input
from usecases.list_users import create_usecase


def create_router(services: IServices) -> APIRouter:
  usecase = create_usecase(services)
  router = APIRouter()

  class ResponseJson(TypedDict):
    users: list[UserJson]

  @router.get("/users")
  async def handle() -> Response:
    input = Input()
    try:
      output = await usecase.run(input)
    except Exception as err:
      print(err)
      raise HTTPException(400, "Bad Request")

    body: ResponseJson = {
      "users": [
        {
          "id": user.id,
          "name": user.name,
        }
        for user in output.users
      ],
    }
    return JSONResponse(body)

  return router
