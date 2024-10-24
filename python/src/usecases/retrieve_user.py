from iservices import IServices
from iservices.user_repo import IUserRepo
from iusecases._utils import UseCase
from iusecases.retrieve_user import Input, Output


def create_usecase(ctx: IServices) -> UseCase[Input, Output]:
  async def run(input: Input) -> Output:
    where = IUserRepo.Where(id=input.user_id)
    user = await ctx.user_repo.pick(where=where)

    if user is None:
      return Output(user=None)

    return Output(user=user.to_entity())

  return UseCase(run)
