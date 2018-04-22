defmodule Beiin.Client do
  require Logger

  alias Beiin.DB.DatabaseClient
  alias Beiin.Worker

  @default_database Beiin.DB.Kairos.Database

  def load(config, opts \\ []) do
    Logger.info(fn -> "Loading data" end)

    RecordServerSupervisor.start_link_load(
      config.metrics,
      config.tags,
      config.record_count,
      config.interval,
      config.record_start
    )

    {db, _} = Keyword.pop(opts, :database, @default_database)
    {:ok} = db.init(config.host, config.port)
    {:ok, db_pid} = DatabaseClient.new(db, config.host, config.port)

    insert_count =
      (length(config.metrics) * length(config.tags) * config.record_count)
      |> Integer.floor_div(config.load_worker_count)

    start = System.monotonic_time(:microsecond)

    1..config.load_worker_count
    |> Enum.map(fn _ -> Task.async(Worker, :run, [:insert, db_pid, insert_count]) end)
    |> Enum.map(fn task -> Task.await(task, 1_000_000_000_000_000) end)
    |> log_results(
      start,
      "output/beiin_load_#{config.record_count}__#{length(config.metrics)}_metrics_#{
        length(config.tags)
      }_tags.txt"
    )
  end

  def run(config, opts \\ []) do
    Logger.info(fn -> "Running test" end)

    RecordServerSupervisor.start_link_run(
      config.metrics,
      config.tags,
      config.record_count,
      config.interval,
      config.record_start
    )

    {db, _} = Keyword.pop(opts, :database, @default_database)
    {:ok} = db.init(config.host, config.port)
    {:ok, db_pid} = DatabaseClient.new(db, config.host, config.port)

    start = System.monotonic_time(:microsecond)
    insert_workers = List.duplicate(:insert, config.insert_worker_count)
    read_workers = List.duplicate(:read, config.read_worker_count)

    [insert_workers | read_workers]
    |> List.flatten()
    |> Enum.map(fn type -> Task.async(Worker, :run, [type, db_pid, config.operation_count]) end)
    |> Enum.map(fn task -> Task.await(task, 1_000_000_000_000_000) end)
    |> log_results(
      start,
      "out.txt"
    )
  end

  defp log_results(results, start, fname) do
    File.open(fname, [:write], fn file ->
      Enum.map(results, fn {operation, latencies} ->
        case operation do
          :insert ->
            Enum.map(latencies, fn l ->
              IO.binwrite(file, "INSERT #{elem(l, 0) - start} #{elem(l, 1)}\n")
            end)

          :read ->
            Enum.map(latencies, fn l ->
              IO.binwrite(file, "READ #{elem(l, 0) - start} #{elem(l, 1)}\n")
            end)
        end
      end)
    end)
  end
end
