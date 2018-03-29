defmodule DatabaseReadWorker do
  use Agent

  def new(database, host, port) do
    read = Currying.curry_many(&database.read/4, [host, port])
    Agent.start_link(fn -> %{f: read} end)
  end

  def exec(pid, metric, timestamp) do
    Agent.get(pid, fn map ->
      {:ok, f} = Map.fetch(map, :f)
      f.(metric).(timestamp)
    end)
  end
end

defmodule DatabaseInsertWorker do
  use Agent

  def new(database, host, port) do
    insert = Currying.curry_many(&database.insert/5, [host, port])
    Agent.start_link(fn -> %{f: insert} end)
  end

  def exec(pid, metric, timestamp, value) do
    Agent.get(pid, fn map ->
      {:ok, f} = Map.fetch(map, :f)
      f.(metric).(timestamp).(value)
    end)
  end
end
