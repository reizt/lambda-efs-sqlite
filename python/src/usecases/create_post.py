from iservices import IServices
from iservices.post_repo import IPostRepo
from iusecases._utils import UseCase
from iusecases.create_post import Input, Output


def create_usecase(ctx: IServices) -> UseCase[Input, Output]:
  async def run(input: Input) -> Output:
    create_data = IPostRepo.CreateData(
      user_id=input.user_id,
      title=input.title,
      content=input.content,
    )
    await ctx.post_repo.create(create_data)

    return Output()

  return UseCase(run)
