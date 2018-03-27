defmodule KairosDatabase do
  @behaviour Database
  require Logger

  defp create_metric_map(metric, timestamp, value, tags \\ %{}) do
    %KairosMetric{name: metric, datapoints: [[timestamp, value]], tags: tags}
  end

  def init(host, port) do
    Logger.info fn -> "Setting up kairos database" end

    {:ok, 0}
  end

  def insert(host, port, metric, timestamp, value) do
    Logger.debug fn -> "Inserting value #{value} into metric '#{metric}' at #{timestamp}" end

    url = "#{host}:#{port}/api/v1/datapoints"
    data = create_metric_map(metric, timestamp, value) |> Poison.encode!()

    HTTPoison.post(url, data, [{"Content-Type", "application/json"}]) |> IO.inspect()

    {:ok, 0}
  end

  def read(host, port, metric, timestamp) do
    Logger.debug fn -> "Reading value of #{metric} at #{timestamp}" end

    {:ok, 0}
  end
end
