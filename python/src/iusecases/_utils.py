from typing import Any, Callable, Coroutine, Generic, TypeVar

Input = TypeVar("Input")
Output = TypeVar("Output")


class UseCase(Generic[Input, Output]):
  def __init__(self, run: Callable[[Input], Coroutine[Any, Any, Output]]):
    self.run = run
