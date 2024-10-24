from typing import TypedDict

from fastapi import APIRouter, HTTPException, Response
from fastapi.responses import JSONResponse

from handlers._shared import UserJson
from iservices import IServices
from iusecases.retrieve_user import Input
from usecases.retrieve_user import create_usecase


def create_router(services: IServices) -> APIRouter:
  usecase = create_usecase(services)
  router = APIRouter()

  class ResponseJson(TypedDict):
    user: UserJson

  @router.get("/users/{user_id}")
  async def handle(user_id: int) -> Response:
    input = Input(user_id=user_id)
    try:
      output = await usecase.run(input)
    except Exception as err:
      print(err)
      raise HTTPException(400, "Bad Request")

    if output.user is None:
      raise HTTPException(404, "Not Found")

    body: ResponseJson = {
      "user": {
        "id": output.user.id,
        "name": output.user.name,
      },
    }
    return JSONResponse(body)

  return router
