defmodule KairosQueryTest do
  use ExUnit.Case

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
  end

  describe "Poison.encode! KairosQueryResult" do
    test "Encoding entire KairosQueryResult returns json object" do
      query_result = %KairosQueryResult{name: "test", group_by: [], tags: %{}, values: []}
      expected = ~s({"values":[],"tags":{},"name":"test","group_by":[]})
      assert Poison.encode!(query_result) == expected
    end
  end

  describe "Poison.decode! KairosQueryResult" do
    test "Decoding entire KairosQueryResult returns json object" do
      data = ~s({"values":[],"tags":{},"name":"test","group_by":[]})
      expected = %KairosQueryResult{name: "test", group_by: [], tags: %{}, values: []}
      assert Poison.decode!(data, as: %KairosQueryResult{}) == expected
    end
  end
end
