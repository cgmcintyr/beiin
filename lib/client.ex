defmodule Client do
  require Logger

  @default_database KairosDatabase
  @host "localhost"
  @port 8080
  @metric "localhost"
  @record_count 1_000
  @insert_start 1_522_331_174_000
  @interval 1000

  def load(_, opts \\ []) do
    Logger.info(fn -> "Loading data" end)
    {:ok, tsg_pid} = TimestampGenerator.new(@insert_start, @interval, @record_count)

    {db, _} = Keyword.pop(opts, :database, @default_database)
    db.init("localhost", 8080)

    {:ok, db_pid} = DatabaseClient.new(db, @host, @port)

    load_loop(@metric, tsg_pid, db_pid, @record_count)
  end

  def run(_, opts \\ []) do
    Logger.info(fn -> "Running client" end)
    {:ok, tsg_pid} = TimestampGenerator.new(@insert_start, @interval, @record_count)

    {db, _} = Keyword.pop(opts, :database, @default_database)
    db.init("localhost", 8080)

    {:ok, db_pid} = DatabaseClient.new(db, @host, @port)

    run_loop(@metric, tsg_pid, db_pid, @record_count)
  end

  defp run_loop(_, _, _, 0) do
  end

  defp run_loop(metric, tsg_pid, db_pid, n) do
    if rem(n, 100) === 0 do
      Logger.info(fn -> "Operations performed: #{@record_count - n}" end)
    end

    DatabaseClient.read(db_pid, metric, TimestampGenerator.rand_timestamp(tsg_pid))
    run_loop(metric, tsg_pid, db_pid, n - 1)
  end

  defp load_loop(_, _, _, 0) do
  end

  defp load_loop(metric, tsg_pid, db_pid, n) do
    if rem(n, 100) === 0 do
      Logger.info(fn -> "Operations performed: #{@record_count - n}" end)
    end

    value = :rand.uniform(1_000_000_000)
    DatabaseClient.insert(db_pid, metric, TimestampGenerator.next_timestamp(tsg_pid), value)
    load_loop(metric, tsg_pid, db_pid, n - 1)
  end
end
