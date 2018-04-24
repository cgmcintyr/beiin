defmodule Beiin.DB.DatabaseClient do
  use Agent

  def new(database, host, port) do
    read = Currying.curry_many(&database.read/5, [host, port])
    insert = Currying.curry_many(&database.insert/6, [host, port])
    Agent.start_link(fn -> %{read_fun: read, insert_fun: insert} end)
  end

  def read(pid, metric, timestamp, tags) do
    {:ok, f} = Agent.get(pid, fn map -> Map.fetch(map, :read_fun) end)
    f.(metric).(timestamp).(tags)
  end

  def insert(pid, metric, timestamp, value, tags) do
    {:ok, f} = Agent.get(pid, fn map -> Map.fetch(map, :insert_fun) end)
    f.(metric).(timestamp).(value).(tags)
  end
end
