from iservices import IServices
from iusecases._utils import UseCase
from iusecases.get_users import Input, Output


def create_usecase(ctx: IServices) -> UseCase[Input, Output]:
  async def run(input: Input) -> Output:
    users = await ctx.user_repo.list()

    return Output(users=[x.to_entity() for x in users])

  return UseCase(run)
