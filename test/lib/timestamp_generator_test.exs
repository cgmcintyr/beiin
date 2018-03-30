defmodule TimestampGeneratorTest do
  use ExUnit.Case

  test "Getting start_time of new TimestampGenerator returns initialised start_time" do
    start_time = 1000
    {:ok, pid} = TimestampGenerator.new(start_time, 2000)
    assert TimestampGenerator.get_start_time(pid) == start_time
  end

  test "Getting interval of new TimestampGenerator returns initialised interval" do
    interval = 1000
    {:ok, pid} = TimestampGenerator.new(2000, interval)
    assert TimestampGenerator.get_interval(pid) == interval
  end

  test "Timestamp of new TimestampGenerator is initialised start_time" do
    start_time = 1000
    {:ok, pid} = TimestampGenerator.new(start_time, 2000)
    assert TimestampGenerator.get_timestamp(pid) == start_time
  end

  test "TimestampGenerator.next increments timestamp by interval" do
    start_time = 1000
    interval = 2000
    {:ok, pid} = TimestampGenerator.new(start_time, interval)
    assert TimestampGenerator.next_timestamp(pid) == start_time + interval
  end

  test "Calling TimestampGenerator.next twice increments timestamp by interval * 2" do
    start_time = 1000
    interval = 2000
    {:ok, pid} = TimestampGenerator.new(start_time, interval)
    TimestampGenerator.next_timestamp(pid)
    assert TimestampGenerator.next_timestamp(pid) == start_time + interval * 2
  end

  test "TimestampGenerators are independent of one another" do
    start_time = 1000
    interval = 2000

    {:ok, pid1} = TimestampGenerator.new(start_time, interval)
    {:ok, pid2} = TimestampGenerator.new(start_time, interval)
    TimestampGenerator.next_timestamp(pid2)

    assert TimestampGenerator.next_timestamp(pid1) == start_time + interval
    assert TimestampGenerator.next_timestamp(pid2) == start_time + interval * 2
  end
end
