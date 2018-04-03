defmodule Beiin.TimestampGenerator do
  def new(start_time, interval, record_count, opts \\ []) do
    Agent.start_link(
      fn ->
        %{
          start_time: start_time,
          interval: interval,
          timestamp: start_time - interval,
          record_count: record_count
        }
      end,
      opts
    )
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

  def rand_timestamp(pid) do
    Agent.get(pid, fn map ->
      {:ok, interval} = Map.fetch(map, :interval)
      {:ok, record_count} = Map.fetch(map, :record_count)
      {:ok, start_time} = Map.fetch(map, :start_time)

      ts =
        (start_time + :rand.uniform(interval * record_count))
        |> Integer.floor_div(interval)
        |> Kernel.*(interval)

      ts
    end)
  end
end
