defmodule Beiin.Record do
  defstruct metric: "name", tags: %{"default" => "value"}, timestamp: 0, value: 0
end

defmodule RecordServer do
  use GenServer

  ## Client API

  def start_link(metrics, tag_maps, tsg_ref \\ TimestampGenerator, opts \\ []) do
    init_map = %{
      metrics: metrics,
      next_records: [],
      tag_maps: tag_maps,
      tsg_ref: tsg_ref
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

  defp generate_next_records(metrics, tag_maps, tsg_ref) do
    timestamp = TimestampGenerator.next_timestamp(tsg_ref)

    Enum.map(metrics, fn metric -> %Beiin.Record{metric: metric, timestamp: timestamp} end)
    |> Enum.map(fn record -> Enum.map(tag_maps, fn t -> %{record | tags: t} end) end)
    |> List.flatten()
  end

  def handle_call({:next}, _from, map) do
    {:ok, metrics} = Map.fetch(map, :metrics)
    {:ok, tag_maps} = Map.fetch(map, :tag_maps)
    {:ok, tsg_ref} = Map.fetch(map, :tsg_ref)

    {next, new_map} =
      Map.get_and_update(map, :next_records, fn records ->
        [next | rs] =
          case records do
            [] -> generate_next_records(metrics, tag_maps, tsg_ref)
            _ -> records
          end

        {next, rs}
      end)

    {:reply, next, new_map}
  end
end
