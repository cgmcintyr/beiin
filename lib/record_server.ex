defmodule RecordServer do
  use GenServer

  ## Client API

  def start_link(metrics, opts \\ []) do
    init_map = %{metrics: metrics}
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
    records = Enum.map(metrics, fn (metric) -> %Beiin.Record{metric: metric, tags: %{}} end)
    {:reply, records, map}
  end
end
