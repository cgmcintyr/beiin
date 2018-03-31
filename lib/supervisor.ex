defmodule RecordServerSupervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    metrics = ["metric_1", "metric_2"]
    tags = [%{host: "default"}]
    record_count = 10
    interval = 1000
    start_time = 0

    children = [
      %{
        id: RecordServer,
        start:
          {RecordServer, :start_link, [metrics, tags, start_time, interval, [name: RecordServer]]}
      },
      %{
        id: TimestampGenerator,
        start:
          {TimestampGenerator, :new,
           [start_time, interval, record_count, [name: TimestampGenerator]]}
      }
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
