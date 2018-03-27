defmodule KairosMetricTest do
  use ExUnit.Case

  describe "Poison.encode! KairosMetric" do
    test "Encoding entire KairosMetric returns json object" do
      metric = %KairosMetric{name: "", datapoints: [], tags: %{}}
      expected = ~s({"tags":{},"name":"","datapoints":[]})
      assert Poison.encode!(metric) == expected
    end

    test "KairosMetric with string value for name encoded correctly" do
      metric = %KairosMetric{name: "test", datapoints: [], tags: %{}}
      expected = ~s("name":"test")
      assert Poison.encode!(metric) =~ expected
    end

    test "KairosMetric with list value for datapoints encoded correctly" do
      metric = %KairosMetric{name: "test", datapoints: [1234], tags: %{}}
      expected = ~s("datapoints":[1234])
      assert Poison.encode!(metric) =~ expected
    end

    test "KairosMetric with %{string=>string} map value for tags encoded correctly" do
      metric = %KairosMetric{name: "test", datapoints: [1234], tags: %{"test" => "test"}}
      expected = ~s("tags":{"test":"test"})
      assert Poison.encode!(metric) =~ expected
    end
  end
end
