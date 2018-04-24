defmodule Beiin.Worker do
  require Logger
  use Task

  alias Beiin.RecordServer
  alias Beiin.DB.DatabaseClient

  def start_link(type, db_client, operations) do
    Task.start_link(__MODULE__, :run, [type, db_client, operations])
  end

  def run(type, db_client, operations) do
    Logger.info(fn -> "Worker #{Kernel.inspect(self())} running #{type} #{operations}" end)

    case type do
      :insert -> inserts(db_client, operations, [])
      :read -> reads(db_client, operations, [])
    end
  end

  defp inserts(_, 0, ls) do
    {:insert, ls}
  end

  defp inserts(db_client, n, ls) do
    value = :rand.uniform(1_000_000_000)
    record = RecordServer.next_insert(RecordServer)

    sent_at = System.monotonic_time(:microsecond)
    res = DatabaseClient.insert(db_client, record.metric, record.timestamp, value, record.tags)

    case res do
      {:ok, latency} -> inserts(db_client, n - 1, [{sent_at, latency} | ls])
      {:error, _} -> inserts(db_client, n - 1, ls)
    end
  end

  defp reads(_, 0, ls) do
    {:read, ls}
  end

  defp reads(db_client, n, ls) do
    record = RecordServer.next_read(RecordServer)
    sent_at = System.monotonic_time(:microsecond)

    res = DatabaseClient.read(db_client, record.metric, record.timestamp, record.tags)

    case res do
      {:ok, latency} -> reads(db_client, n - 1, [{sent_at, latency} | ls])
      {:error, _} -> reads(db_client, n - 1, ls)
    end
  end
end
