defmodule DatabaseReadWorker do
  use Agent

  def new(database) do
    read = Currying.curry_many(&database.read/4, ['localhost', 8080])
    Agent.start_link(fn -> %{f: read} end)
  end

  def exec(pid, timestamp) do
    Agent.get(pid, fn map ->
      {:ok, f} = Map.fetch(map, :f)
      f.("localhost").(timestamp)
    end)
  end
end

defmodule DatabaseInsertWorker do
  use Agent

  def new(fun) do
    # insert = Currying.curry_many(&db.read/4, ['localhost', 8080])
    Agent.start_link(fn -> %{f: fun} end)
  end

  def exec(pid, timestamp, value) do
    Agent.get(pid, fn map ->
      {:ok, f} = Map.fetch(map, :f)
      f.(timestamp).(value)
    end)
  end
end
