defmodule KairosDatabase do
  @behaviour Database
  require Logger

  defp create_metric_map(metric, timestamp, value, tags \\ %{}) do
    %KairosMetric{name: metric, datapoints: [[timestamp, value]], tags: tags}
  end

  def init(host, port) do
    Logger.info(fn -> "Setting up kairos database at #{host}:#{port}" end)

    {:ok, 0}
  end

  def insert(host, port, metric, timestamp, value) do
    Logger.debug(fn -> "Inserting value #{value} into metric '#{metric}' at #{timestamp}" end)

    url = "#{host}:#{port}/api/v1/datapoints"
    data = create_metric_map(metric, timestamp, value) |> Poison.encode!()
    args = [url, data, [{"Content-Type", "application/json"}]]

    {optime, response} = :timer.tc(&HTTPoison.post/3, args)

    Logger.info(fn ->
      "Insert ran in #{optime / 1_000_000} with response #{response |> elem(0)}"
    end)

    {:ok, optime}
  end

  def read(host, port, metric, timestamp) do
    Logger.debug(fn -> "Reading value of #{metric} at #{timestamp}" end)

    url = "#{host}:#{port}/api/v1/datapoints/query"

    data =
      '{"start_absolute":1234,"end_absolute":1235,"metrics":[{"tags":{},"name":"localhost","limit":10}]}'

    args = [url, data, [{"Content-Type", "application/json"}]]

    {optime, response} = :timer.tc(&HTTPoison.post/3, args)
    IO.inspect(response)

    Logger.info(fn -> "Read ran in #{optime / 1_000_000} with response #{response |> elem(0)}" end)

    {:ok, optime}
  end
end
