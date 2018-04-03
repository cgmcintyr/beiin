defmodule Beiin.DB.Kairos.Database do
  alias Beiin.DB.Kairos.Metric

  @behaviour Beiin.DB.Database
  @kairos_database_request Application.get_env(:beiin, :kairos_database_request)

  require Logger

  def init(host, port) do
    Logger.info(fn -> "Setting up kairos database at #{host}:#{port}" end)
    response = HTTPoison.get!("http://#{host}:#{port}/api/v1/health/check")

    case response.status_code do
      204 -> {:ok}
      _ -> {:error, "Kairos failed health check"}
    end
  end

  def insert(host, port, metric, timestamp, value, tags \\ %{}) do
    Logger.debug(fn -> "Inserting value #{value} into metric '#{metric}' at #{timestamp}" end)

    url = "#{host}:#{port}/api/v1/datapoints"
    data = create_metric_map(metric, timestamp, value, tags) |> Poison.encode!()
    headers = [{"Content-Type", "application/json"}]

    {:ok, optime, response} = @kairos_database_request.timed_post(url, data, headers)

    Logger.debug(fn ->
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

    Logger.debug(fn ->
      "Read ran in #{optime / 1_000_000} with status code #{response.status_code}"
    end)

    {:ok, optime}
  end

  defp create_metric_map(metric, timestamp, value, tags \\ %{default: "default"}) do
    %Metric{name: metric, datapoints: [[timestamp, value]], tags: tags}
  end
end
