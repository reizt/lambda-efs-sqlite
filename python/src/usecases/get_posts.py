from iservices import IServices
from iusecases._utils import UseCase
from iusecases.get_posts import Input, Output


def create_usecase(ctx: IServices) -> UseCase[Input, Output]:
  async def run(input: Input) -> Output:
    posts = await ctx.post_repo.list()

    return Output(posts=[x.to_entity() for x in posts])

  return UseCase(run)
