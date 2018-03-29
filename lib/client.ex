defmodule Client do
  require Logger

  @default_database KairosDatabase
  @host "localhost"
  @port 8080
  @metric "localhost"
  @record_count 5

  def run(msg, opts \\ []) do
    Logger.info(fn -> "Running client" end)
    {:ok, tsg_pid} = TimestampGenerator.new(1_522_331_174_000, 1000)

    {db, opts} = Keyword.pop(opts, :database, @default_database)
    db.init("localhost", 8080)

    {:ok, db_pid} = DatabaseClient.new(db, @host, @port)

    loop(@metric, tsg_pid, db_pid, @record_count)
  end

  defp loop(_, _, _, 0) do
  end

  defp loop(metric, tsg_pid, db_pid, n) do
    value = :rand.uniform(1_000_000_000)
    DatabaseClient.insert(db_pid, metric, TimestampGenerator.next_timestamp(tsg_pid), value)
    DatabaseClient.read(db_pid, metric, TimestampGenerator.get_timestamp(tsg_pid))
    loop(metric, tsg_pid, db_pid, n - 1)
  end
end
