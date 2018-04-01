defmodule Client do
  require Logger

  @default_database KairosDatabase
  @host "localhost"
  @port 8080
  @metrics ["localhost"]
  @tags [%{host: "test_host"}]
  @record_count 1_000
  @insert_start 1_522_331_174_000
  @interval 1000

  def load(_, opts \\ []) do
    Logger.info(fn -> "Loading data" end)

    LoadRecordServerSupervisor.start_link(
      @metrics,
      @tags,
      @record_count,
      @interval,
      @insert_start
    )

    {db, _} = Keyword.pop(opts, :database, @default_database)
    db.init("localhost", 8080)

    {:ok, db_pid} = DatabaseClient.new(db, @host, @port)

    load_loop(db_pid, @record_count)
  end

  def run(_) do
    Logger.error(fn -> "Run has not been implemented yet" end)
  end

  defp load_loop(_, 0) do
  end

  defp load_loop(db_pid, n) do
    if rem(n, 100) === 0 do
      Logger.info(fn -> "Operations performed: #{@record_count - n}" end)
    end

    value = :rand.uniform(1_000_000_000)
    record = RecordServer.next(RecordServer)
    DatabaseClient.insert(db_pid, record.metric, record.timestamp, value, record.tags)
    load_loop(db_pid, n - 1)
  end
end
