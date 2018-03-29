defmodule DatabaseWorkerTest do
  use ExUnit.Case, async: true

  import Mox

  setup :verify_on_exit!

  describe "DatbaseReadWorker Tests" do
    test "Run applies database module's read function" do
      response = %HTTPoison.Response{ body: "{}", headers: [{}], status_code: 200 }
      KairosDatabase.MockRequest
        |> expect(:timed_post, fn(_, _, _) -> {:ok, 1000, response} end)

      {:ok, pid} = DatabaseReadWorker.new(KairosDatabase)
      KairosDatabase.MockRequest |> allow(self(), pid)

      assert DatabaseReadWorker.exec(pid, 0) == {:ok, 1000}
    end
  end
end
