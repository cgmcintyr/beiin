defmodule RecordServerSupervisor do
  use Supervisor

  def start_link(metrics, tags, record_count, interval, start_time, opts \\ []) do
    children = [
      %{
        id: RecordServer,
        start:
          {RecordServer, :start_link, [metrics, tags, [name: RecordServer]]}
      },
      %{
        id: TimestampGenerator,
        start:
          {TimestampGenerator, :new,
           [start_time, interval, record_count, [name: TimestampGenerator]]}
      }
    ]

    Supervisor.start_link(__MODULE__, children, opts)
  end

  def init(children) do
    Supervisor.init(children, strategy: :one_for_one)
  end
end
