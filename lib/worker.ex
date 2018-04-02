defmodule Worker do
  require Logger
  use Task

  def start_link(type, operations, db_client) do
    Task.start_link(__MODULE__, :run, [type, operations, db_client])
  end

  def run(type, db_client, operations) do
    Logger.info(fn -> "Worker #{Kernel.inspect(self())} running #{type} #{operations}" end)
    case type do
      :insert -> inserts(db_client, operations)
      :read -> reads(db_client, operations)
    end
  end

  defp inserts(_, 0) do
  end

  defp inserts(db_client, n) do
    value = :rand.uniform(1_000_000_000)
    record = RecordServer.next_insert(RecordServer)
    DatabaseClient.insert(db_client, record.metric, record.timestamp, value, record.tags)
    inserts(db_client, n - 1)
  end

  defp reads(_, _) do
    Logger.error(fn -> "Worker.reads not implemented" end)
  end
end
