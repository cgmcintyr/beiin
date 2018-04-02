defmodule Client do
  require Logger

  @default_database KairosDatabase
  @host "localhost"
  @port 8080
  @metrics ["new_metric", "two_metric"]
  @tags [%{host: "test_host"}]
  @record_count 1_000
  @operation_count 100
  @insert_start 1_522_331_174_000
  @interval 1000

  def load(_, opts \\ []) do
    Logger.info(fn -> "Loading data" end)

    RecordServerSupervisor.start_link_load(
      @metrics,
      @tags,
      @record_count,
      @interval,
      @insert_start
    )

    {db, _} = Keyword.pop(opts, :database, @default_database)
    db.init("localhost", 8080)
    {:ok, db_pid} = DatabaseClient.new(db, @host, @port)

    worker_count = 10
    insert_count = length(@metrics) * length(@tags) * @record_count
    worker_insert_count = Integer.floor_div(insert_count, worker_count)

    1..worker_count
    |> Enum.map(fn _ -> Task.async(Worker, :run, [:insert, db_pid, worker_insert_count]) end)
    |> Enum.map(fn task -> Task.await(task, 1_000_000) end)
    |> log_results("load.txt")
  end

  def run(_, opts \\ []) do
    Logger.info(fn -> "Running test" end)

    RecordServerSupervisor.start_link_run(
      @metrics,
      @tags,
      @record_count,
      @interval,
      @insert_start
    )

    {db, _} = Keyword.pop(opts, :database, @default_database)
    db.init("localhost", 8080)
    {:ok, db_pid} = DatabaseClient.new(db, @host, @port)

    insert_worker_count = 5
    read_worker_count = 5

    [List.duplicate(:insert, insert_worker_count) | List.duplicate(:read, read_worker_count)] 
    |> List.flatten
    |> Enum.map(fn type -> Task.async(Worker, :run, [type, db_pid, @operation_count]) end)
    |> Enum.map(fn task -> Task.await(task, 1_000_000) end)
    |> log_results("run2.txt")
  end

  defp log_results(results, fname) do
    File.open(fname, [:write], fn file ->
      Enum.map(results, fn {operation, latencies} ->
        case operation do
          :insert -> Enum.map(latencies, fn(l) -> IO.binwrite(file, "INSERT #{l}\n") end)
          :read -> Enum.map(latencies, fn(l) -> IO.binwrite(file, "READ #{l}\n") end)
        end
      end)
    end)
  end
end
