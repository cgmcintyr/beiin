defmodule TimestampGenerator do
  def new(start_time, interval) do
    Agent.start_link(fn ->
      %{start_time: start_time, interval: interval, timestamp: start_time - interval}
    end)
  end

  def get_timestamp(pid) do
    Agent.get(pid, &Map.get(&1, :timestamp))
  end

  def get_interval(pid) do
    Agent.get(pid, &Map.get(&1, :interval))
  end

  def get_start_time(pid) do
    Agent.get(pid, &Map.get(&1, :start_time))
  end

  def next_timestamp(pid) do
    Agent.get_and_update(pid, fn map ->
      {:ok, i} = Map.fetch(map, :interval)
      new_map = Map.update!(map, :timestamp, fn value -> value + i end)
      {:ok, ts} = Map.fetch(new_map, :timestamp)
      {ts, new_map}
    end)
  end
end
