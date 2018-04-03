defmodule Beiin.DB.Kairos.Request do
  @callback timed_post(
              url :: String.t(),
              data :: String.t(),
              headers :: []
            ) :: {:ok, optime :: integer, response :: map()}
end

defmodule Beiin.DB.Kairos.Request.HTTP do
  @behaviour Beiin.DB.Kairos.Request

  def timed_post(url, data, headers) do
    {optime, {:ok, response}} = :timer.tc(&HTTPoison.post/3, [url, data, headers])
    {:ok, optime, response}
  end
end
