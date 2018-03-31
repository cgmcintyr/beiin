defmodule RecordServerSupervisor do
  use Supervisor

  @metrics ["metric_1", "metric_2"]
  @tags %{host: "default"}

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    children = [
      %{
        id: RecordServer,
        start: {RecordServer, :start_link, [@metrics, @tags, 1000, 1000, [name: RecordServer]]}
      }
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
