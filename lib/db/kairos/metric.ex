defmodule KairosMetric do
  @derive [Poison.Encoder]
  defstruct name: "metric", datapoints: [], tags: %{}
end

defimpl Poison.Encoder, for: KairosMetric do
  def encode(%{name: name, datapoints: datapoints, tags: tags}, options) do
    Poison.Encoder.encode(
      %{
        "name" => name,
        "datapoints" => datapoints,
        "tags" => tags
      },
      options
    )
  end
end
