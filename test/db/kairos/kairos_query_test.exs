defmodule Beiin.DB.Kairos.Query.Test do
  use ExUnit.Case

  alias Beiin.DB.Kairos.Query, as: KairosQuery
  alias Beiin.DB.Kairos.QueryResult, as: KairosQueryResult
  alias Beiin.DB.Kairos.QueryResultValue, as: KairosQueryResultValue

  describe "Poison.encode! KairosQuery" do
    test "Encoding entire KairosQuery returns json object" do
      query = %KairosQuery{sample_size: 1, results: []}
      expected = ~s({"sample_size":1,"results":[]})
      assert Poison.encode!(query) == expected
    end
  end

  describe "Poison.decode! KairosQuery" do
    test "Decoding entire KairosQuery returns json object" do
      data = ~s({"sample_size":1,"results":[]})
      expected = %KairosQuery{sample_size: 1, results: []}
      assert Poison.decode!(data, as: %KairosQuery{}) == expected
    end

    test "Decoding KairosQuery results are list of KairosQueryResults" do
      data_results =
        Enum.join(
          [
            "[",
            ~s({"values":[[1234,4321]],"tags":{},"name":"test","group_by":[]}),
            ",",
            ~s({"values":[[5678,8765]],"tags":{},"name":"test","group_by":[]}),
            "]"
          ],
          ""
        )

      data = ~s({"sample_size":2,"results":#{data_results}})

      expected_results = [
        %KairosQueryResult{
          name: "test",
          group_by: [],
          tags: %{},
          values: [%KairosQueryResultValue{timestamp: 1234, value: 4321}]
        },
        %KairosQueryResult{
          name: "test",
          group_by: [],
          tags: %{},
          values: [%KairosQueryResultValue{timestamp: 5678, value: 8765}]
        }
      ]

      decoded = Poison.decode!(data, as: %KairosQuery{})
      assert decoded.sample_size == 2
      Enum.map(expected_results, fn r -> assert Enum.member?(decoded.results, r) end)
    end
  end

  describe "Poison.encode! KairosQueryResult" do
    test "Encoding entire KairosQueryResult returns json object" do
      query_result = %KairosQueryResult{name: "test", group_by: [], tags: %{}, values: []}
      expected = ~s({"values":[],"tags":{},"name":"test","group_by":[]})
      assert Poison.encode!(query_result) == expected
    end

    test "Encoding KairosQueryResult with integer values list" do
      values = [[1234, 4321], [5678, 8765]]
      query_result = %KairosQueryResult{name: "test", group_by: [], tags: %{}, values: values}
      expected_to_contain = ~s("values":[[1234,4321],[5678,8765]])
      assert Poison.encode!(query_result) =~ expected_to_contain
    end

    test "Encoding KairosQueryResult with KairosQueryResultValue values list" do
      values = [
        %KairosQueryResultValue{timestamp: 1234, value: 4321},
        %KairosQueryResultValue{timestamp: 5678, value: 8765}
      ]

      query_result = %KairosQueryResult{name: "test", group_by: [], tags: %{}, values: values}
      expected_to_contain = ~s("values":[[1234,4321],[5678,8765]])
      assert Poison.encode!(query_result) =~ expected_to_contain
    end
  end

  describe "Poison.decode! KairosQueryResult" do
    test "Decoding entire KairosQueryResult returns json object" do
      data = ~s({"values":[],"tags":{},"name":"test","group_by":[]})
      expected = %KairosQueryResult{name: "test", group_by: [], tags: %{}, values: []}
      assert Poison.decode!(data, as: %KairosQueryResult{}) == expected
    end

    test "Decoding KairosQueryResult with KairosQueryResultValue values list" do
      values = [
        %KairosQueryResultValue{timestamp: 1234, value: 4321},
        %KairosQueryResultValue{timestamp: 5678, value: 8765}
      ]

      data = ~s({"values":[[1234,4321],[5678,8765]],"tags":{},"name":"test","group_by":[]})
      decoded = Poison.decode!(data, as: %KairosQueryResult{})
      Enum.map(values, fn v -> assert Enum.member?(decoded.values, v) end)
    end
  end
end
