defmodule Beiin.Record do
  defstruct metric: "name", tags: %{"default" => "value"}, timestamp: 0, value: 0
end

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
    {:ok, map}
  end

  defp generate_next_records(metrics, tag_maps) do
    timestamp = TimestampGenerator.next_timestamp(TimestampGenerator)

    Enum.map(metrics, fn metric -> %Beiin.Record{metric: metric, timestamp: timestamp} end)
    |> Enum.map(fn record -> Enum.map(tag_maps, fn t -> %{record | tags: t} end) end)
    |> List.flatten()
  end

  def handle_call({:next}, _from, map) do
    {:ok, metrics} = Map.fetch(map, :metrics)
    {:ok, tag_maps} = Map.fetch(map, :tag_maps)

    {next, new_map} =
      Map.get_and_update(map, :next_records, fn records ->
        [next | rs] =
          case records do
            [] -> generate_next_records(metrics, tag_maps)
            _ -> records
          end

        {next, rs}
      end)

    {:reply, next, new_map}
  end
end
