defmodule DatabaseClient do
  use Agent

  def new(database, host, port) do
    read = Currying.curry_many(&database.read/4, [host, port])
    insert = Currying.curry_many(&database.insert/6, [host, port])
    Agent.start_link(fn -> %{read_fun: read, insert_fun: insert} end)
  end

  def read(pid, metric, timestamp) do
    Agent.get(pid, fn map ->
      {:ok, f} = Map.fetch(map, :read_fun)
      f.(metric).(timestamp)
    end)
  end

  def insert(pid, metric, timestamp, value, tags) do
    Agent.get(pid, fn map ->
      {:ok, f} = Map.fetch(map, :insert_fun)
      f.(metric).(timestamp).(value).(tags)
    end)
  end
end
