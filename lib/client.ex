defmodule Client do
  require Logger

  @default_database KairosDatabase

  def run(msg, opts \\ []) do
    Logger.info(fn -> "Running client" end)
    {:ok, tsg_pid} = TimestampGenerator.new(1_522_331_174_000, 1000)

    {db, opts} = Keyword.pop(opts, :database, @default_database)
    db.init("localhost", 8080)

    read = Currying.curry_many(&db.insert/5, ['localhost', 8080])
    insert = Currying.curry_many(&db.read/4, ['localhost', 8080])

    loop("localhost", tsg_pid, read, insert, 5)
  end

  defp loop(_, _, _, _, 0) do
  end

  defp loop(metric, tsg_pid, read_fun, ins_fun, n) do
    value = :rand.uniform(1_000_000_000)
    read_fun.(metric).(TimestampGenerator.next_timestamp(tsg_pid)).(value)
    ins_fun.(metric).(TimestampGenerator.get_timestamp(tsg_pid))
    loop(metric, tsg_pid, read_fun, ins_fun, n - 1)
  end
end
