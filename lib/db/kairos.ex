defmodule KairosDatabase do
  @behaviour Database

  def init(host, port) do
    IO.puts("db init")
    IO.puts(host)
    IO.puts(port)
    {:ok, 0}
  end

  def insert(timestamp, value) do
    IO.puts("db insert")
    IO.puts(timestamp)
    IO.puts(value)
    {:ok, 0}
  end

  def read(timestamp, value) do
    IO.puts("db read")
    IO.puts(timestamp)
    IO.puts(value)
    {:ok, 0}
  end
end
