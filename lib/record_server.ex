defmodule RecordServer do
  use GenServer

  ## Client API

  def start_link(metrics, tag_maps \\ [%{}], start_time \\ :os.system_time(:millisecond), opts \\ []) do
    init_map = %{metrics: metrics, tag_maps: tag_maps, start_time: start_time}
    GenServer.start_link(__MODULE__, init_map, opts)
  end

  def next(server) do
    GenServer.call(server, {:next})
  end

  ## Server Callbacks
  def init(map) do
    {:ok, map}
  end

  def handle_call({:next}, _from, map) do
    {:ok, metrics} = Map.fetch(map, :metrics)
    {:ok, tag_maps} = Map.fetch(map, :tag_maps)
    {:ok, start_time} = Map.fetch(map, :start_time)

    records =
      Enum.map(metrics, fn metric -> %Beiin.Record{metric: metric, timestamp: start_time} end)
      |> Enum.map(fn record -> Enum.map(tag_maps, fn t -> %{record | tags: t} end) end)
      |> List.flatten()

    {:reply, records, map}
  end
end
