from typing import TypedDict

from fastapi import APIRouter, HTTPException, Response
from fastapi.responses import JSONResponse

from handlers._shared import PostJson
from iservices import IServices
from iusecases.retrieve_post import Input
from usecases.retrieve_post import create_usecase


def create_router(services: IServices) -> APIRouter:
  usecase = create_usecase(services)
  router = APIRouter()

  class ResponseJson(TypedDict):
    post: PostJson

  @router.get("/posts/{post_id}")
  async def handle(post_id: int) -> Response:
    input = Input(post_id=post_id)
    try:
      output = await usecase.run(input)
    except Exception as err:
      print(err)
      raise HTTPException(400, "Bad Request")

    if output.post is None:
      raise HTTPException(404, "Not Found")

    body: ResponseJson = {
      "post": {
        "id": output.post.id,
        "user_id": output.post.user_id,
        "title": output.post.title,
        "content": output.post.content,
      },
    }
    return JSONResponse(body)

  return router
