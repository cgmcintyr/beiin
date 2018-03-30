defmodule RecordServerTest do
  use ExUnit.Case, async: true

  test "RecordServer with 1 metric returns list with 1 record" do
    metrics = ["test_metric_1"]

    rserver_spec = %{id: RecordServer, start: {RecordServer, :start_link, [metrics]}}
    rserver = start_supervised!(rserver_spec)

    [record] = RecordServer.next(rserver)
    assert record.metric == hd(metrics)
  end

  test "RecordServer with 1 metric 1 tag map returns record with tag map" do
    metrics = ["test_metric_1"]
    tags = [%{test: "test_tag"}]

    rserver_spec = %{id: RecordServer, start: {RecordServer, :start_link, [metrics, tags]}}
    rserver = start_supervised!(rserver_spec)

    [record] = RecordServer.next(rserver)
    assert record.tags == hd(tags)
  end

  test "RecordServer with N metrics returns record for each metric" do
    metrics = ["test_metric_1", "test_metric_2"]

    rserver_spec = %{id: RecordServer, start: {RecordServer, :start_link, [metrics]}}
    rserver = start_supervised!(rserver_spec)

    records = RecordServer.next(rserver)
    assert length(records) == length(metrics)

    record_metrics = Enum.map(records, fn r -> r.metric end)
    assert Enum.all?(metrics, fn metric -> Enum.member?(record_metrics, metric) end)
  end

  test "RecordServer with N metrics returns N records with matching timestamps" do
    metrics = ["test_metric_1", "test_metric_2"]

    rserver_spec = %{id: RecordServer, start: {RecordServer, :start_link, [metrics]}}
    rserver = start_supervised!(rserver_spec)

    [record | records] = RecordServer.next(rserver)
    t = record.timestamp
    assert Enum.all?(records, fn record -> record.timestamp == t end)
  end

  test "RecordServer with N metrics and M tag maps returns N*M records" do
    metrics = ["test_metric_1", "test_metric_2", "test_metric_3"]
    tags = [%{host: "test_host_1"}, %{host: "test_host_2"}]

    rserver_spec = %{id: RecordServer, start: {RecordServer, :start_link, [metrics, tags]}}
    rserver = start_supervised!(rserver_spec)

    records = RecordServer.next(rserver)
    assert length(metrics) * length(tags) == length(records)

    record_metrics = Enum.map(records, fn record -> record.metric end)
    record_tags = Enum.map(records, fn record -> record.tags end)

    assert Enum.all?(metrics, fn m -> Enum.member?(record_metrics, m) end)
    assert Enum.all?(tags, fn t -> Enum.member?(record_tags, t) end)
  end
end
