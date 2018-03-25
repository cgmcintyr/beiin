defmodule Client do
  @default_database KairosDatabase

  def run(msg, opts \\ []) do
    IO.puts(msg)
    {database, opts} = Keyword.pop(opts, :database, @default_database)
    IO.inspect(opts)
    database.init("localhost", 8080)
  end
end
