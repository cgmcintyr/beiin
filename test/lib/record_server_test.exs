defmodule RecordServerTest do
  use ExUnit.Case, async: true

  test "RecordServer with 1 metric returns list with 1 record" do
    rserver = start_supervised!({RecordServer, ["test"]})
    [record] = RecordServer.next(rserver)
    assert record.metric == "test"
  end

  test "RecordServer with N metrics returns record for each metric" do
    metrics = ["test_metric_1", "test_metric_2"]
    rserver = start_supervised!({RecordServer, metrics})

    records = RecordServer.next(rserver)
    assert length(records) == length(metrics)

    record_metrics = Enum.map(records, fn(r) -> r.metric end)
    assert Enum.all?(metrics, fn(metric) -> Enum.member?(record_metrics, metric) end)
  end

  test "RecordServer with N metrics returns N records with matching timestamps" do
    metrics = ["test_metric_1", "test_metric_2"]
    rserver = start_supervised!({RecordServer, metrics})

    [record|records] = RecordServer.next(rserver)
    t = record.timestamp
    assert Enum.all?(records, fn(record) -> record.timestamp == t end)
  end
end
