defmodule KairosQueryResult do
  @derive [Poison.Encoder]
  defstruct name: "metric", group_by: [], tags: %{}, values: []
end

defmodule KairosQuery do
  @derive [Poison.Encoder]
  defstruct sample_size: 0, results: []
end

defimpl Poison.Encoder, for: KairosQuery do
  def encode(%{sample_size: sample_size, results: []}, options) do
    Poison.Encoder.encode(
      %{
        "sample_size" => sample_size,
        "results" => []
      },
      options
    )
  end
end
