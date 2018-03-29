defmodule DatabaseWorkerTest do
  use ExUnit.Case, async: true

  @host "localhost"
  @port 9999
  @metric "metric"
  @timestamp 1234
  @value 4321

  defmodule CustomDatabase do
    @behaviour Database
    def init(_, _) do
      {:ok, 0}
    end

    def insert(_, _, _, _, _) do
      {:ok, 1234}
    end

    def read(_, _, _, _) do
      {:ok, 5678}
    end
  end

  describe "DatbaseReadWorker Tests" do
    test "Exec calls databases read function" do
      {:ok, pid} = DatabaseReadWorker.new(CustomDatabase, @host, @port)
      assert DatabaseReadWorker.exec(pid, @metric, @timestamp) == {:ok, 5678}
    end
  end

  describe "DatbaseInsertWorker Tests" do
    test "Exec calls databases insert function" do
      {:ok, pid} = DatabaseInsertWorker.new(CustomDatabase, @host, @port)
      assert DatabaseInsertWorker.exec(pid, @metric, @timestamp, @value) == {:ok, 1234}
    end
  end
end
