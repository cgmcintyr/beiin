defmodule DatabaseReadWorker do
  use Agent

  def new(fun) do
    Agent.start_link(fn -> %{f: fun} end)
  end

  def exec(pid, timestamp) do
    Agent.get(pid, fn map ->
      {:ok, f} = Map.fetch(map, :f)
      f.(timestamp)
    end)
  end
end

defmodule DatabaseInsertWorker do
  use Agent

  def new(fun) do
    Agent.start_link(fn -> %{f: fun} end)
  end

  def exec(pid, timestamp, value) do
    Agent.get(pid, fn map ->
      {:ok, f} = Map.fetch(map, :f)
      f.(timestamp).(value)
    end)
  end
end
