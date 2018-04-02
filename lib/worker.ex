defmodule Worker do
  require Logger
  use Task

  def start_link(type, operations, db_client) do
    Task.start_link(__MODULE__, :run, [type, operations, db_client])
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

    {:ok, latency} =
      DatabaseClient.insert(db_client, record.metric, record.timestamp, value, record.tags)

    inserts(db_client, n - 1, [latency | ls])
  end

  defp reads(_, 0, ls) do
    {:read, ls}
  end

  defp reads(db_client, n, ls) do
    record = RecordServer.next_read(RecordServer)
    {:ok, latency} = DatabaseClient.read(db_client, record.metric, record.timestamp)
    reads(db_client, n - 1, [latency | ls])
  end
end
