defmodule Client do
  require Logger

  @default_database KairosDatabase

  def run(msg, opts \\ []) do
    Logger.info(fn -> "Running client" end)
    {db, opts} = Keyword.pop(opts, :database, @default_database)
    db.init("localhost", 8080)
    db_ins = Currying.curry_many(&db.insert/5, ['localhost', 8080])
    db_ins.("localhost").(1234).(1234)
  end
end
