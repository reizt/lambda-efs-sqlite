from iservices import IServices
from iservices.user_repo import IUserRepo
from iusecases._utils import UseCase
from iusecases.create_user import Input, Output


def create_usecase(ctx: IServices) -> UseCase[Input, Output]:
  async def run(input: Input) -> Output:
    create_data = IUserRepo.CreateData(
      name=input.name,
    )
    await ctx.user_repo.create(create_data)

    return Output()

  return UseCase(run)
