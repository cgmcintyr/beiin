defmodule Beiin.Record do
  defstruct metric: "name", tags: %{"default" => "value"}, timestamp: 0, value: 0
end

defmodule RecordServer do
  use GenServer

  ## Client API

  def start_link(metrics, tag_maps, opts \\ []) do
    {ins_tsg, opts} = Keyword.pop(opts, :ins_tsg, TimestampGenerator)
    {read_tsg, opts} = Keyword.pop(opts, :read_tsg, TimestampGenerator)

    init_map = %{
      metrics: metrics,
      next_ins_records: [],
      next_read_records: [],
      tag_maps: tag_maps,
      ins_tsg: ins_tsg,
      read_tsg: read_tsg
    }

    GenServer.start_link(__MODULE__, init_map, opts)
  end

  def next_insert(server) do
    GenServer.call(server, {:next_insert})
  end

  def next_read(server) do
    GenServer.call(server, {:next_insert})
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

  def handle_call({:next_insert}, _from, map) do
    {:ok, metrics} = Map.fetch(map, :metrics)
    {:ok, tag_maps} = Map.fetch(map, :tag_maps)
    {:ok, ins_tsg} = Map.fetch(map, :ins_tsg)

    {next, new_map} =
      Map.get_and_update(map, :next_ins_records, fn records ->
        [next | rs] =
          case records do
            [] -> generate_next_records(metrics, tag_maps, ins_tsg)
            _ -> records
          end

        {next, rs}
      end)

    {:reply, next, new_map}
  end

  def handle_call({:next_read}, _from, map) do
    {:ok, metrics} = Map.fetch(map, :metrics)
    {:ok, tag_maps} = Map.fetch(map, :tag_maps)
    {:ok, read_tsg} = Map.fetch(map, :read_tsg)

    {next, new_map} =
      Map.get_and_update(map, :next_read_records, fn records ->
        [next | rs] =
          case records do
            [] -> generate_next_records(metrics, tag_maps, read_tsg)
            _ -> records
          end

        {next, rs}
      end)

    {:reply, next, new_map}
  end
end
