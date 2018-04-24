defmodule Beiin.DB.Kairos.Request do
  @callback timed_post(
              url :: String.t(),
              data :: String.t(),
              headers :: []
            ) :: {status :: atom, optime :: integer, response :: map()}
end

defmodule Beiin.DB.Kairos.Request.HTTP do
  @behaviour Beiin.DB.Kairos.Request

  def timed_post(url, data, headers) do
    {optime, {status, response}} = :timer.tc(&HTTPoison.post/3, [url, data, headers])
    {status, optime, response}
  end
end
