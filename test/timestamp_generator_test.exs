defmodule Beiin.TimestampGenerator.Test do
  use ExUnit.Case
  alias Beiin.TimestampGenerator, as: TSG

  @record_count 10

  test "Getting start_time of new TimestampGenerator returns initialised start_time" do
    start_time = 1000
    {:ok, pid} = TSG.new(start_time, 2000, @record_count)
    assert TSG.get_start_time(pid) == start_time
  end

  test "Getting interval of new TimestampGenerator returns initialised interval" do
    interval = 1000
    {:ok, pid} = TSG.new(2000, interval, @record_count)
    assert TSG.get_interval(pid) == interval
  end

  test "Timestamp of new TimestampGenerator is initialised start_time - interval" do
    start_time = 1000
    interval = 1000
    {:ok, pid} = TSG.new(start_time, interval, @record_count)
    assert TSG.get_timestamp(pid) == start_time - interval
  end

  test "TimestampGenerator.next increments timestamp by interval" do
    start_time = 1000
    interval = 2000
    {:ok, pid} = TSG.new(start_time, interval, @record_count)
    TSG.next_timestamp(pid)
    assert TSG.next_timestamp(pid) == start_time + interval
  end

  test "Calling TimestampGenerator.next twice increments timestamp by interval * 2" do
    start_time = 1000
    interval = 2000
    {:ok, pid} = TSG.new(start_time, interval, @record_count)
    TSG.next_timestamp(pid)
    TSG.next_timestamp(pid)
    assert TSG.next_timestamp(pid) == start_time + interval * 2
  end

  test "TimestampGenerators are independent of one another" do
    start_time = 1000
    interval = 2000

    {:ok, pid1} = TSG.new(start_time, interval, @record_count)
    {:ok, pid2} = TSG.new(start_time, interval, @record_count)
    TSG.next_timestamp(pid2)

    assert TSG.next_timestamp(pid1) == start_time
    assert TSG.next_timestamp(pid2) == start_time + interval
  end
end
