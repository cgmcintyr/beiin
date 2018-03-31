defmodule DatabaseClientTest do
  use ExUnit.Case, async: true

  @host "localhost"
  @port 9999
  @metric "metric"
  @timestamp 1234
  @value 4321
  @tags %{test: "test"}

  defmodule CustomDatabase do
    @behaviour Database
    def init(_, _) do
      {:ok, 0}
    end

    def insert(_, _, _, _, _, _) do
      {:ok, 1234}
    end

    def read(_, _, _, _) do
      {:ok, 5678}
    end
  end

  test "DatabaseClient.read calls databases read function" do
    {:ok, pid} = DatabaseClient.new(CustomDatabase, @host, @port)
    assert DatabaseClient.read(pid, @metric, @timestamp) == {:ok, 5678}
  end

  test "DatabaseClient.insert calls databases insert function" do
    {:ok, pid} = DatabaseClient.new(CustomDatabase, @host, @port)
    assert DatabaseClient.insert(pid, @metric, @timestamp, @value, @tags) == {:ok, 1234}
  end
end
