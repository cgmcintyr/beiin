defmodule Workertest do
  use ExUnit.Case, async: true

  test "Worker task returns arg it was run with" do
    assert Worker.run(1) == 1
    assert Worker.run("test") == "test"
    assert Worker.run(%{}) == %{}
  end
end
