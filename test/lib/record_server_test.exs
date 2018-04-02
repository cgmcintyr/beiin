defmodule RecordServerTest do
  use ExUnit.Case, async: true

  defp start_supervised_record_server(
         metrics,
         tags \\ [%{}],
         start_time \\ 0,
         interval \\ 1000,
         record_count \\ 10
       ) do
    rserver_spec = %{
      id: RecordServer,
      start: {RecordServer, :start_link, [metrics, tags]}
    }

    tsg_spec = %{
      id: TimestampGenerator,
      start:
        {TimestampGenerator, :new,
         [start_time, interval, record_count, [name: TimestampGenerator]]}
    }

    start_supervised!(tsg_spec)
    start_supervised!(rserver_spec)
  end

  describe "Calling RecordServer.next_insert" do
    test "with 1 metric returns record for that metric" do
      metrics = ["test_metric_1"]
      rserver = start_supervised_record_server(metrics)

      record = RecordServer.next_insert(rserver)
      assert record.metric == hd(metrics)
    end

    test "with 1 tag map returns record with that tag map" do
      metrics = ["test_metric_2"]
      tags = [%{test: "test_tag"}]
      rserver = start_supervised_record_server(metrics, tags)

      record = RecordServer.next_insert(rserver)
      assert record.tags == hd(tags)
    end

    test "with N metrics and 1 tag map N times returns record for each metric" do
      metrics = ["test_metric_1", "test_metric_2"]
      rserver = start_supervised_record_server(metrics)

      records = [RecordServer.next_insert(rserver), RecordServer.next_insert(rserver)]

      record_metrics = Enum.map(records, fn r -> r.metric end)
      assert Enum.all?(metrics, fn metric -> Enum.member?(record_metrics, metric) end)
    end

    test "with N metrics and 1 tag map N*2 times returns 2 records for each metric" do
      metrics = ["test_metric_1", "test_metric_2"]
      rserver = start_supervised_record_server(metrics)

      records =
        Enum.map(metrics, fn _ ->
          [RecordServer.next_insert(rserver), RecordServer.next_insert(rserver)]
        end)
        |> List.flatten()

      record_metrics = Enum.map(records, fn r -> r.metric end)

      assert Enum.all?(metrics, fn metric ->
               Enum.count(record_metrics, fn record_metric -> metric == record_metric end)
             end)
    end

    test "with N metrics and 1 tag map N times returns N records with start_time" do
      metrics = ["test_metric_1", "test_metric_2"]
      tags = [%{}]
      start_time = 1234
      rserver = start_supervised_record_server(metrics, tags, start_time)

      records = [RecordServer.next_insert(rserver), RecordServer.next_insert(rserver)]
      assert Enum.all?(records, fn record -> record.timestamp == start_time end)
    end

    test "with N metrics and 1 tag map N*2 times returns sets of timestamps incremented by interval" do
      metrics = ["test_metric_1", "test_metric_2"]
      tags = [%{}]
      start_time = 1234
      interval = 4444
      rserver = start_supervised_record_server(metrics, tags, start_time, interval)

      records1 = [RecordServer.next_insert(rserver), RecordServer.next_insert(rserver)]
      records2 = [RecordServer.next_insert(rserver), RecordServer.next_insert(rserver)]

      assert Enum.all?(records1, fn record -> record.timestamp == start_time end)
      assert Enum.all?(records2, fn record -> record.timestamp == start_time + interval end)
    end

    test "with N metrics and M tag maps N*M times returns records for cartesian product of metrics and tags" do
      metrics = ["test_metric_1", "test_metric_2", "test_metric_3"]
      tags = [%{host: "test_host_1"}, %{host: "test_host_2"}]
      rserver = start_supervised_record_server(metrics, tags)

      n = length(metrics)
      m = length(tags)

      records = Enum.map(0..(n * m), fn _ -> RecordServer.next_insert(rserver) end)

      record_metrics = Enum.map(records, fn record -> record.metric end)
      record_tags = Enum.map(records, fn record -> record.tags end)

      assert Enum.all?(metrics, fn m -> Enum.member?(record_metrics, m) end)
      assert Enum.all?(tags, fn t -> Enum.member?(record_tags, t) end)
    end
  end

  describe "Calling RecordServer.next_read" do
    test "with 1 metric returns record for that metric" do
      metrics = ["test_metric_1"]
      rserver = start_supervised_record_server(metrics)

      record = RecordServer.next_read(rserver)
      assert record.metric == hd(metrics)
    end

    test "with 1 tag map returns record with that tag map" do
      metrics = ["test_metric_2"]
      tags = [%{test: "test_tag"}]
      rserver = start_supervised_record_server(metrics, tags)

      record = RecordServer.next_read(rserver)
      assert record.tags == hd(tags)
    end

    test "with N metrics and 1 tag map N times returns record for each metric" do
      metrics = ["test_metric_1", "test_metric_2"]
      rserver = start_supervised_record_server(metrics)

      records = [RecordServer.next_read(rserver), RecordServer.next_read(rserver)]

      record_metrics = Enum.map(records, fn r -> r.metric end)
      assert Enum.all?(metrics, fn metric -> Enum.member?(record_metrics, metric) end)
    end

    test "with N metrics and 1 tag map N*2 times returns 2 records for each metric" do
      metrics = ["test_metric_1", "test_metric_2"]
      rserver = start_supervised_record_server(metrics)

      records =
        Enum.map(metrics, fn _ ->
          [RecordServer.next_read(rserver), RecordServer.next_read(rserver)]
        end)
        |> List.flatten()

      record_metrics = Enum.map(records, fn r -> r.metric end)

      assert Enum.all?(metrics, fn metric ->
               Enum.count(record_metrics, fn record_metric -> metric == record_metric end)
             end)
    end

    test "with N metrics and 1 tag map N times returns N records with start_time" do
      metrics = ["test_metric_1", "test_metric_2"]
      tags = [%{}]
      start_time = 1234
      rserver = start_supervised_record_server(metrics, tags, start_time)

      records = [RecordServer.next_read(rserver), RecordServer.next_read(rserver)]
      assert Enum.all?(records, fn record -> record.timestamp == start_time end)
    end

    test "with N metrics and 1 tag map N*2 times returns sets of timestamps incremented by interval" do
      metrics = ["test_metric_1", "test_metric_2"]
      tags = [%{}]
      start_time = 1234
      interval = 4444
      rserver = start_supervised_record_server(metrics, tags, start_time, interval)

      records1 = [RecordServer.next_read(rserver), RecordServer.next_read(rserver)]
      records2 = [RecordServer.next_read(rserver), RecordServer.next_read(rserver)]

      assert Enum.all?(records1, fn record -> record.timestamp == start_time end)
      assert Enum.all?(records2, fn record -> record.timestamp == start_time + interval end)
    end

    test "with N metrics and M tag maps N*M times returns records for cartesian product of metrics and tags" do
      metrics = ["test_metric_1", "test_metric_2", "test_metric_3"]
      tags = [%{host: "test_host_1"}, %{host: "test_host_2"}]
      rserver = start_supervised_record_server(metrics, tags)

      n = length(metrics)
      m = length(tags)

      records = Enum.map(0..(n * m), fn _ -> RecordServer.next_read(rserver) end)

      record_metrics = Enum.map(records, fn record -> record.metric end)
      record_tags = Enum.map(records, fn record -> record.tags end)

      assert Enum.all?(metrics, fn m -> Enum.member?(record_metrics, m) end)
      assert Enum.all?(tags, fn t -> Enum.member?(record_tags, t) end)
    end
  end
end
