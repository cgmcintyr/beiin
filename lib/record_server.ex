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
    init_map = %{metrics: metrics, tag_maps: tag_maps, start_time: start_time, interval: interval}
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

  def handle_call({:next}, _from, map) do
    {:ok, metrics} = Map.fetch(map, :metrics)
    {:ok, tag_maps} = Map.fetch(map, :tag_maps)
    {:ok, tsg_pid} = Map.fetch(map, :tsg_pid)
    timestamp = TimestampGenerator.next_timestamp(tsg_pid)

    records =
      Enum.map(metrics, fn metric -> %Beiin.Record{metric: metric, timestamp: timestamp} end)
      |> Enum.map(fn record -> Enum.map(tag_maps, fn t -> %{record | tags: t} end) end)
      |> List.flatten()

    {:reply, records, map}
  end

  def handle_info({:DOWN, ref, :process, from_pid, reason}, state) do
    IO.inspect(%{
      ref: ref,
      from_pid: from_pid,
      reason: reason
    })
  end
end
