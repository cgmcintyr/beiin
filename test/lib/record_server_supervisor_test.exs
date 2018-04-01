defmodule LoadRecordServerSupervisorTest do
  use ExUnit.Case

  @metrics ["test"]
  @tags [%{}]
  @record_count 10
  @start_time 0
  @interval 1000


  test "LoadRecordServerSupervisor restarts RecordServer on crash" do
    LoadRecordServerSupervisor.start_link(@metrics, @tags, @record_count, @interval, @start_time)

    pid = Process.whereis(RecordServer)
    ref = Process.monitor(pid)
    Process.exit(pid, :kill)
    receive do
      {:DOWN, ^ref, :process, ^pid, :killed} ->
        :timer.sleep 1
        assert is_pid(Process.whereis(RecordServer))
    after
      1000 ->
        raise :timeout
    end
  end

  test "LoadRecordServerSupervisor restarts TimestampGenerator on crash" do
    LoadRecordServerSupervisor.start_link(@metrics, @tags, @record_count, @interval, @start_time)

    pid = Process.whereis(TimestampGenerator)
    ref = Process.monitor(pid)
    Process.exit(pid, :kill)
    receive do
      {:DOWN, ^ref, :process, ^pid, :killed} ->
        :timer.sleep 1
        assert is_pid(Process.whereis(TimestampGenerator))
    after
      1000 ->
        raise :timeout
    end
  end
end
