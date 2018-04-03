defmodule Beiin.DB.Kairos.QueryResultValue do
  @derive [Poison.Encoder]
  defstruct timestamp: 0, value: 0
end

defmodule Beiin.DB.Kairos.QueryResult do
  @derive [Poison.Encoder]
  defstruct name: "metric", group_by: [], tags: %{}, values: []
end

defmodule Beiin.DB.Kairos.Query do
  alias Beiin.DB.Kairos.QueryResult
  @derive [Poison.Encoder]
  defstruct sample_size: 0, results: [%QueryResult{}]
end

defimpl Poison.Encoder, for: Beiin.DB.Kairos.QueryResultValue do
  def encode(%{timestamp: timestamp, value: value}, options) do
    Poison.Encoder.encode([timestamp, value], options)
  end
end

defimpl Poison.Encoder, for: Beiin.DB.Kairos.QueryResult do
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

defimpl Poison.Decoder, for: Beiin.DB.Kairos.QueryResult do
  alias Beiin.DB.Kairos.QueryResultValue

  defp to_result_value([timestamp, value]) do
    %QueryResultValue{timestamp: timestamp, value: value}
  end

  def decode(query_result, options) do
    %{query_result | values: Enum.map(query_result.values, fn v -> to_result_value(v) end)}
  end
end

defimpl Poison.Encoder, for: Beiin.DB.Kairos.Query do
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
