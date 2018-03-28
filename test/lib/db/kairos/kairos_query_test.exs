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
end
