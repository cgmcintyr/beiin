defmodule Beiin.DB.Kairos.Metric do
  @derive [Poison.Encoder]
  defstruct name: "metric", datapoints: [], tags: %{"default" => "value"}
end

defimpl Poison.Encoder, for: Beiin.DB.Kairos.Metric do
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
