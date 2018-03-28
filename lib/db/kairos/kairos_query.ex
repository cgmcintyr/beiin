defmodule KairosQueryResultValue do
  @derive [Poison.Encoder]
  defstruct timestamp: 0, value: 0
end

defmodule KairosQueryResult do
  @derive [Poison.Encoder]
  defstruct name: "metric", group_by: [], tags: %{}, values: []
end

defmodule KairosQuery do
  @derive [Poison.Encoder]
  defstruct sample_size: 0, results: [%KairosQueryResult{}]
end

defimpl Poison.Encoder, for: KairosQueryResultValue do
  def encode(%{timestamp: timestamp, value: value}, options) do
    Poison.Encoder.encode([timestamp, value], options)
  end
end

defimpl Poison.Encoder, for: KairosQueryResult do
  def encode(%{name: name, group_by: group_by, tags: tags, values: values}, options) do
    Poison.Encoder.encode(
      %{
        name: name,
        group_by: group_by,
        tags: tags,
        values: values
      },
      options
    )
  end
end

defimpl Poison.Decoder, for: KairosQueryResult do
  defp to_result_value([timestamp, value]) do
    %KairosQueryResultValue{timestamp: timestamp, value: value}
  end

  def decode(query_result, options) do
    %{query_result | values: Enum.map(query_result.values, fn v -> to_result_value(v) end)}
  end
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
