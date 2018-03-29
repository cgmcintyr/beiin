defmodule KairosDatabase.Request do
  @callback timed_post(url :: String.t(), data :: String.t(), headers :: []) ::
              {:ok, optime :: integer, response :: map()}
end

defmodule KairosDatabase.Request.HTTP do
  @behaviour KairosDatabase.Request

  def timed_post(url, data, headers) do
    {optime, {:ok, response}} = :timer.tc(&HTTPoison.post/3, [url, data, headers])
    {:ok, optime, response}
  end
end

defmodule KairosDatabase do
  @behaviour Database
  @kairos_database_request Application.get_env(:beiin, :kairos_database_request)

  require Logger

  defp create_metric_map(metric, timestamp, value, tags \\ %{default: "default"}) do
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
    headers = [{"Content-Type", "application/json"}]

    {:ok, optime, response} = @kairos_database_request.timed_post(url, data, headers)

    Logger.info(fn ->
      "Insert ran in #{optime / 1_000_000} with status code #{response.status_code}"
    end)

    {:ok, optime}
  end

  def read(host, port, metric, timestamp, tags \\ %{default: "default"}) do
    Logger.debug(fn -> "Reading value of #{metric} at #{timestamp}" end)

    url = "#{host}:#{port}/api/v1/datapoints/query"
    encoded_tags = Poison.encode!(tags)

    data =
      '{"start_absolute":#{timestamp},"end_absolute":#{timestamp + 1},"metrics":[{"tags":#{
        encoded_tags
      },"name":"#{metric}","limit":10}]}'

    headers = [{"Content-Type", "application/json"}]

    {:ok, optime, response} = @kairos_database_request.timed_post(url, data, headers)

    Logger.info(fn ->
      "Read ran in #{optime / 1_000_000} with status code #{response.status_code}"
    end)

    {:ok, optime}
  end
end
