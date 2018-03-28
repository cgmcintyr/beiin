defmodule KairosQueryTest do
  use ExUnit.Case

  describe "Poison.encode! KairosQuery" do
    test "Encoding entire KairosQuery returns json object" do
      metric = %KairosQuery{sample_size: 1, results: []}
      expected = ~s({"sample_size":1,"results":[]})
      assert Poison.encode!(metric) == expected
    end
  end
end
