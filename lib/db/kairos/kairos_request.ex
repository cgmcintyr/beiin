defmodule KairosDatabase.Request do
  @callback timed_post(
              url :: String.t(),
              data :: String.t(),
              headers :: []
            ) :: {:ok, optime :: integer, response :: map()}
end

defmodule KairosDatabase.Request.HTTP do
  @behaviour KairosDatabase.Request

  def timed_post(url, data, headers) do
    {optime, {:ok, response}} = :timer.tc(&HTTPoison.post/3, [url, data, headers])
    {:ok, optime, response}
  end
end
