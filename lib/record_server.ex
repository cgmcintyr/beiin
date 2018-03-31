defmodule RecordServer do
  use GenServer

  ## Client API

  def start_link(
        metrics,
        tag_maps \\ [%{}],
        start_time \\ :os.system_time(:millisecond),
        interval \\ 1000,
        opts \\ []
      ) do
    init_map = %{
      metrics: metrics,
      tag_maps: tag_maps,
      start_time: start_time,
      interval: interval,
      next_records: []
    }

    GenServer.start_link(__MODULE__, init_map, opts)
  end

  def next(server) do
    GenServer.call(server, {:next})
  end

  ## Server Callbacks
  def init(map) do
    {start_time, m1} = Map.pop(map, :start_time)
    {interval, m2} = Map.pop(m1, :interval)

    {:ok, pid} = TimestampGenerator.new(start_time, interval)
    {:ok, Map.merge(m2, %{tsg_pid: pid})}
  end

  defp generate_next_records(metrics, tag_maps, tsg_pid) do
    timestamp = TimestampGenerator.next_timestamp(tsg_pid)

    Enum.map(metrics, fn metric -> %Beiin.Record{metric: metric, timestamp: timestamp} end)
    |> Enum.map(fn record -> Enum.map(tag_maps, fn t -> %{record | tags: t} end) end)
    |> List.flatten()
  end

  def handle_call({:next}, _from, map) do
    {:ok, metrics} = Map.fetch(map, :metrics)
    {:ok, tag_maps} = Map.fetch(map, :tag_maps)
    {:ok, tsg_pid} = Map.fetch(map, :tsg_pid)

    {next, new_map} =
      Map.get_and_update(map, :next_records, fn records ->
        [next|rs] = case records do
          [] -> generate_next_records(metrics, tag_maps, tsg_pid)
          _ -> records
        end
        {next, rs}
      end)

    {:reply, next, new_map}
  end
end
