defmodule KairosDatabase do
  @behaviour Database

  defp create_metric_map(metric, timestamp, value, tags \\ %{}) do
    %KairosMetric{name: metric, datapoints: [[timestamp, value]], tags: tags}
  end

  def init(host, port) do
    IO.puts("db init")
    IO.puts(host)
    IO.puts(port)
    {:ok, 0}
  end

  def insert(metric, timestamp, value) do
    create_metric_map(metric, timestamp, value) |> Poison.encode!() |> IO.inspect()
    {:ok, 0}
  end

  def read(metric, timestamp, value) do
    IO.puts("db read")
    IO.puts(timestamp)
    IO.puts(value)
    {:ok, 0}
  end
end
